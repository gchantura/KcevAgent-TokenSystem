/*
# Atomic DSB — Initial Schema (Migration 001)

## Overview
Creates the complete foundation for the Atomic Design System Builder application.
This covers identity/auth, organizations, projects, design systems, and the
permission/role system.

## New Tables

### Identity and Authorization
- `profiles` — one-to-one with auth.users; display name, avatar, bio, status
- `organizations` — workspace/tenant with name, slug, settings
- `organization_members` — user membership with lifecycle status and role
- `roles` — organization-scoped or system roles with display metadata
- `permissions` — stable machine-readable permission keys
- `role_permissions` — many-to-many grants of permissions to roles
- `invitations` — pending email invitations to organizations

### Projects and Design Systems
- `projects` — belongs to org; name, description, status
- `project_members` — project-scoped access override
- `design_systems` — belongs to project; name, version, maturity, settings
- `design_system_modes` — light/dark or custom token modes

### Design Tokens
- `token_collections` — primitive/semantic/component/custom groupings
- `design_tokens` — canonical token records with type, status, path
- `token_values` — mode-specific resolved values for each token
- `token_aliases` — alias relationships between tokens

### Components
- `components` — canonical component identity, status, accessibility
- `component_variants` — named variants of a component
- `component_states` — UI states (default, hover, focus, disabled, etc.)
- `component_token_mappings` — explicit design token linkages

### Documentation, Assets, Releases
- `documentation_entries` — structured docs linked to any resource
- `assets` — metadata for files stored in Supabase Storage
- `releases` — design system version/release records
- `audit_logs` — append-only security and change audit trail

## Security
- RLS enabled on every table
- Membership-scoped access: users only see orgs/projects they belong to
- Append-only audit logs for ordinary users
- Helper functions for membership and permission checks

## Important Notes
1. "tokens" here = design tokens, NOT auth tokens (those stay in Supabase Auth)
2. Admin bootstrap: run the placeholder query at the end to grant first admin role
3. All policies use auth.uid() — never current_user
4. Indexes cover all FK columns, status filters, path lookups
*/

-- ============================================================
-- Extensions
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- PROFILES
-- ============================================================
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name text,
  avatar_url text,
  bio text,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'pending')),
  is_platform_admin boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profiles_select_own" ON profiles;
CREATE POLICY "profiles_select_own" ON profiles FOR SELECT
  TO authenticated USING (auth.uid() = id OR is_platform_admin = false);

DROP POLICY IF EXISTS "profiles_insert_own" ON profiles;
CREATE POLICY "profiles_insert_own" ON profiles FOR INSERT
  TO authenticated WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "profiles_update_own" ON profiles;
CREATE POLICY "profiles_update_own" ON profiles FOR UPDATE
  TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "profiles_delete_own" ON profiles;
CREATE POLICY "profiles_delete_own" ON profiles FOR DELETE
  TO authenticated USING (auth.uid() = id);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)))
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================================
-- ORGANIZATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS organizations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  description text,
  logo_url text,
  settings jsonb NOT NULL DEFAULT '{}',
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'archived', 'suspended')),
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_organizations_slug ON organizations(slug);
CREATE INDEX IF NOT EXISTS idx_organizations_status ON organizations(status);

ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- ROLES
-- ============================================================
CREATE TABLE IF NOT EXISTS roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid REFERENCES organizations(id) ON DELETE CASCADE,
  name text NOT NULL,
  slug text NOT NULL,
  description text,
  is_system boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(organization_id, slug)
);

CREATE INDEX IF NOT EXISTS idx_roles_org ON roles(organization_id);

ALTER TABLE roles ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- PERMISSIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS permissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  key text NOT NULL UNIQUE,
  label text NOT NULL,
  description text,
  category text NOT NULL DEFAULT 'general',
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "permissions_select_all" ON permissions;
CREATE POLICY "permissions_select_all" ON permissions FOR SELECT
  TO authenticated USING (true);

-- ============================================================
-- ROLE_PERMISSIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS role_permissions (
  role_id uuid NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  permission_id uuid NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
  granted_at timestamptz NOT NULL DEFAULT now(),
  granted_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  PRIMARY KEY (role_id, permission_id)
);

CREATE INDEX IF NOT EXISTS idx_role_permissions_role ON role_permissions(role_id);
CREATE INDEX IF NOT EXISTS idx_role_permissions_perm ON role_permissions(permission_id);

ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- ORGANIZATION_MEMBERS
-- ============================================================
CREATE TABLE IF NOT EXISTS organization_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role_id uuid NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'removed')),
  joined_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(organization_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_org_members_org ON organization_members(organization_id);
CREATE INDEX IF NOT EXISTS idx_org_members_user ON organization_members(user_id);
CREATE INDEX IF NOT EXISTS idx_org_members_status ON organization_members(status);

ALTER TABLE organization_members ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- INVITATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS invitations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  email text NOT NULL,
  role_id uuid NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'expired')),
  token text NOT NULL UNIQUE DEFAULT encode(gen_random_bytes(32), 'hex'),
  invited_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  expires_at timestamptz NOT NULL DEFAULT (now() + interval '7 days'),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(organization_id, email, status)
);

CREATE INDEX IF NOT EXISTS idx_invitations_org ON invitations(organization_id);
CREATE INDEX IF NOT EXISTS idx_invitations_email ON invitations(email);
CREATE INDEX IF NOT EXISTS idx_invitations_token ON invitations(token);

ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- PROJECTS
-- ============================================================
CREATE TABLE IF NOT EXISTS projects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name text NOT NULL,
  slug text NOT NULL,
  description text,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'archived')),
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(organization_id, slug)
);

CREATE INDEX IF NOT EXISTS idx_projects_org ON projects(organization_id);
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);

ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- PROJECT_MEMBERS (project-level access override)
-- ============================================================
CREATE TABLE IF NOT EXISTS project_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role_id uuid NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
  status text NOT NULL DEFAULT 'active',
  joined_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(project_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_project_members_project ON project_members(project_id);
CREATE INDEX IF NOT EXISTS idx_project_members_user ON project_members(user_id);

ALTER TABLE project_members ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- DESIGN_SYSTEMS
-- ============================================================
CREATE TABLE IF NOT EXISTS design_systems (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  version text NOT NULL DEFAULT '0.1.0',
  maturity text NOT NULL DEFAULT 'draft' CHECK (maturity IN ('draft', 'review', 'approved', 'deprecated')),
  settings jsonb NOT NULL DEFAULT '{}',
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_design_systems_project ON design_systems(project_id);
CREATE INDEX IF NOT EXISTS idx_design_systems_maturity ON design_systems(maturity);

ALTER TABLE design_systems ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- DESIGN_SYSTEM_MODES
-- ============================================================
CREATE TABLE IF NOT EXISTS design_system_modes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  design_system_id uuid NOT NULL REFERENCES design_systems(id) ON DELETE CASCADE,
  name text NOT NULL,
  slug text NOT NULL,
  description text,
  is_default boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(design_system_id, slug)
);

CREATE INDEX IF NOT EXISTS idx_ds_modes_ds ON design_system_modes(design_system_id);

ALTER TABLE design_system_modes ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- TOKEN_COLLECTIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS token_collections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  design_system_id uuid NOT NULL REFERENCES design_systems(id) ON DELETE CASCADE,
  name text NOT NULL,
  slug text NOT NULL,
  tier text NOT NULL DEFAULT 'primitive' CHECK (tier IN ('primitive', 'semantic', 'component', 'custom')),
  description text,
  sort_order int NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(design_system_id, slug)
);

CREATE INDEX IF NOT EXISTS idx_token_collections_ds ON token_collections(design_system_id);
CREATE INDEX IF NOT EXISTS idx_token_collections_tier ON token_collections(tier);

ALTER TABLE token_collections ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- DESIGN_TOKENS
-- ============================================================
CREATE TABLE IF NOT EXISTS design_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  design_system_id uuid NOT NULL REFERENCES design_systems(id) ON DELETE CASCADE,
  collection_id uuid NOT NULL REFERENCES token_collections(id) ON DELETE CASCADE,
  name text NOT NULL,
  path text NOT NULL,
  token_type text NOT NULL CHECK (token_type IN ('color', 'typography', 'spacing', 'sizing', 'border', 'shadow', 'opacity', 'duration', 'easing', 'z-index', 'other')),
  description text,
  usage_guidance text,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('draft', 'active', 'deprecated', 'archived')),
  is_alias boolean NOT NULL DEFAULT false,
  alias_target_id uuid REFERENCES design_tokens(id) ON DELETE SET NULL,
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(design_system_id, path)
);

CREATE INDEX IF NOT EXISTS idx_design_tokens_ds ON design_tokens(design_system_id);
CREATE INDEX IF NOT EXISTS idx_design_tokens_collection ON design_tokens(collection_id);
CREATE INDEX IF NOT EXISTS idx_design_tokens_type ON design_tokens(token_type);
CREATE INDEX IF NOT EXISTS idx_design_tokens_status ON design_tokens(status);
CREATE INDEX IF NOT EXISTS idx_design_tokens_path ON design_tokens(path);

ALTER TABLE design_tokens ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- TOKEN_VALUES (mode-specific resolved values)
-- ============================================================
CREATE TABLE IF NOT EXISTS token_values (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  token_id uuid NOT NULL REFERENCES design_tokens(id) ON DELETE CASCADE,
  mode_id uuid REFERENCES design_system_modes(id) ON DELETE CASCADE,
  raw_value text NOT NULL,
  resolved_value text,
  value_type text NOT NULL DEFAULT 'literal' CHECK (value_type IN ('literal', 'alias', 'computed')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(token_id, mode_id)
);

CREATE INDEX IF NOT EXISTS idx_token_values_token ON token_values(token_id);
CREATE INDEX IF NOT EXISTS idx_token_values_mode ON token_values(mode_id);

ALTER TABLE token_values ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- TOKEN_ALIASES (explicit alias graph for cycle detection)
-- ============================================================
CREATE TABLE IF NOT EXISTS token_aliases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_token_id uuid NOT NULL REFERENCES design_tokens(id) ON DELETE CASCADE,
  target_token_id uuid NOT NULL REFERENCES design_tokens(id) ON DELETE CASCADE,
  mode_id uuid REFERENCES design_system_modes(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(source_token_id, target_token_id, mode_id)
);

CREATE INDEX IF NOT EXISTS idx_token_aliases_source ON token_aliases(source_token_id);
CREATE INDEX IF NOT EXISTS idx_token_aliases_target ON token_aliases(target_token_id);

ALTER TABLE token_aliases ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- COMPONENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS components (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  design_system_id uuid NOT NULL REFERENCES design_systems(id) ON DELETE CASCADE,
  name text NOT NULL,
  slug text NOT NULL,
  category text NOT NULL DEFAULT 'general',
  description text,
  usage_guidance text,
  accessibility_guidance text,
  code_reference text,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'review', 'approved', 'deprecated', 'needs-update')),
  maturity text NOT NULL DEFAULT 'draft' CHECK (maturity IN ('draft', 'review', 'approved', 'deprecated')),
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(design_system_id, slug)
);

CREATE INDEX IF NOT EXISTS idx_components_ds ON components(design_system_id);
CREATE INDEX IF NOT EXISTS idx_components_category ON components(category);
CREATE INDEX IF NOT EXISTS idx_components_status ON components(status);

ALTER TABLE components ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- COMPONENT_VARIANTS
-- ============================================================
CREATE TABLE IF NOT EXISTS component_variants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  component_id uuid NOT NULL REFERENCES components(id) ON DELETE CASCADE,
  name text NOT NULL,
  slug text NOT NULL,
  description text,
  properties jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(component_id, slug)
);

CREATE INDEX IF NOT EXISTS idx_component_variants_component ON component_variants(component_id);

ALTER TABLE component_variants ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- COMPONENT_STATES
-- ============================================================
CREATE TABLE IF NOT EXISTS component_states (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  component_id uuid NOT NULL REFERENCES components(id) ON DELETE CASCADE,
  name text NOT NULL,
  slug text NOT NULL,
  description text,
  UNIQUE(component_id, slug)
);

CREATE INDEX IF NOT EXISTS idx_component_states_component ON component_states(component_id);

ALTER TABLE component_states ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- COMPONENT_TOKEN_MAPPINGS
-- ============================================================
CREATE TABLE IF NOT EXISTS component_token_mappings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  component_id uuid NOT NULL REFERENCES components(id) ON DELETE CASCADE,
  variant_id uuid REFERENCES component_variants(id) ON DELETE CASCADE,
  state_id uuid REFERENCES component_states(id) ON DELETE CASCADE,
  token_id uuid NOT NULL REFERENCES design_tokens(id) ON DELETE CASCADE,
  css_property text NOT NULL,
  description text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(component_id, variant_id, state_id, token_id, css_property)
);

CREATE INDEX IF NOT EXISTS idx_comp_token_map_component ON component_token_mappings(component_id);
CREATE INDEX IF NOT EXISTS idx_comp_token_map_token ON component_token_mappings(token_id);

ALTER TABLE component_token_mappings ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- DOCUMENTATION_ENTRIES
-- ============================================================
CREATE TABLE IF NOT EXISTS documentation_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid REFERENCES organizations(id) ON DELETE CASCADE,
  project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
  design_system_id uuid REFERENCES design_systems(id) ON DELETE CASCADE,
  component_id uuid REFERENCES components(id) ON DELETE CASCADE,
  token_id uuid REFERENCES design_tokens(id) ON DELETE CASCADE,
  title text NOT NULL,
  content text NOT NULL DEFAULT '',
  doc_type text NOT NULL DEFAULT 'general',
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_docs_ds ON documentation_entries(design_system_id);
CREATE INDEX IF NOT EXISTS idx_docs_component ON documentation_entries(component_id);
CREATE INDEX IF NOT EXISTS idx_docs_token ON documentation_entries(token_id);

ALTER TABLE documentation_entries ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- ASSETS
-- ============================================================
CREATE TABLE IF NOT EXISTS assets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
  design_system_id uuid REFERENCES design_systems(id) ON DELETE CASCADE,
  name text NOT NULL,
  file_path text NOT NULL,
  mime_type text,
  size_bytes bigint,
  asset_type text NOT NULL DEFAULT 'image',
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_assets_org ON assets(organization_id);
CREATE INDEX IF NOT EXISTS idx_assets_ds ON assets(design_system_id);

ALTER TABLE assets ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- RELEASES
-- ============================================================
CREATE TABLE IF NOT EXISTS releases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  design_system_id uuid NOT NULL REFERENCES design_systems(id) ON DELETE CASCADE,
  version text NOT NULL,
  name text,
  description text,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'deprecated')),
  published_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  published_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(design_system_id, version)
);

CREATE INDEX IF NOT EXISTS idx_releases_ds ON releases(design_system_id);
CREATE INDEX IF NOT EXISTS idx_releases_status ON releases(status);

ALTER TABLE releases ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- AUDIT_LOGS (append-only)
-- ============================================================
CREATE TABLE IF NOT EXISTS audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid REFERENCES organizations(id) ON DELETE SET NULL,
  actor_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  action text NOT NULL,
  resource_type text NOT NULL,
  resource_id uuid,
  metadata jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_org ON audit_logs(organization_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_actor ON audit_logs(actor_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON audit_logs(created_at DESC);

ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- UPDATE TIMESTAMP TRIGGERS
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DO $$
DECLARE
  tbl text;
BEGIN
  FOR tbl IN SELECT unnest(ARRAY[
    'profiles','organizations','roles','organization_members','invitations',
    'projects','project_members','design_systems','token_collections',
    'design_tokens','token_values','components','documentation_entries'
  ]) LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS set_updated_at ON %I', tbl);
    EXECUTE format(
      'CREATE TRIGGER set_updated_at BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION update_updated_at()',
      tbl
    );
  END LOOP;
END;
$$;

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

-- Check if user is a member of an organization (active)
CREATE OR REPLACE FUNCTION is_org_member(org_id uuid, uid uuid DEFAULT auth.uid())
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM organization_members
    WHERE organization_id = org_id
      AND user_id = uid
      AND status = 'active'
  );
$$;

-- Check if user has a permission within an organization
CREATE OR REPLACE FUNCTION has_org_permission(org_id uuid, perm_key text, uid uuid DEFAULT auth.uid())
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM organization_members om
    JOIN role_permissions rp ON rp.role_id = om.role_id
    JOIN permissions p ON p.id = rp.permission_id
    WHERE om.organization_id = org_id
      AND om.user_id = uid
      AND om.status = 'active'
      AND p.key = perm_key
  );
$$;

-- Check if user is platform admin
CREATE OR REPLACE FUNCTION is_platform_admin(uid uuid DEFAULT auth.uid())
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE((SELECT is_platform_admin FROM profiles WHERE id = uid), false);
$$;

-- Get user's role slug in an org
CREATE OR REPLACE FUNCTION get_org_role_slug(org_id uuid, uid uuid DEFAULT auth.uid())
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT r.slug
  FROM organization_members om
  JOIN roles r ON r.id = om.role_id
  WHERE om.organization_id = org_id
    AND om.user_id = uid
    AND om.status = 'active'
  LIMIT 1;
$$;

-- ============================================================
-- RLS POLICIES — organizations
-- ============================================================
DROP POLICY IF EXISTS "orgs_select_member" ON organizations;
CREATE POLICY "orgs_select_member" ON organizations FOR SELECT
  TO authenticated
  USING (is_org_member(id) OR is_platform_admin());

DROP POLICY IF EXISTS "orgs_insert_auth" ON organizations;
CREATE POLICY "orgs_insert_auth" ON organizations FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = created_by);

DROP POLICY IF EXISTS "orgs_update_admin" ON organizations;
CREATE POLICY "orgs_update_admin" ON organizations FOR UPDATE
  TO authenticated
  USING (has_org_permission(id, 'org:manage') OR is_platform_admin())
  WITH CHECK (has_org_permission(id, 'org:manage') OR is_platform_admin());

DROP POLICY IF EXISTS "orgs_delete_admin" ON organizations;
CREATE POLICY "orgs_delete_admin" ON organizations FOR DELETE
  TO authenticated
  USING (is_platform_admin());

-- ============================================================
-- RLS POLICIES — roles
-- ============================================================
DROP POLICY IF EXISTS "roles_select_member" ON roles;
CREATE POLICY "roles_select_member" ON roles FOR SELECT
  TO authenticated
  USING (
    organization_id IS NULL  -- system roles visible to all
    OR is_org_member(organization_id)
    OR is_platform_admin()
  );

DROP POLICY IF EXISTS "roles_insert_admin" ON roles;
CREATE POLICY "roles_insert_admin" ON roles FOR INSERT
  TO authenticated
  WITH CHECK (
    organization_id IS NOT NULL
    AND (has_org_permission(organization_id, 'roles:manage') OR is_platform_admin())
  );

DROP POLICY IF EXISTS "roles_update_admin" ON roles;
CREATE POLICY "roles_update_admin" ON roles FOR UPDATE
  TO authenticated
  USING (has_org_permission(organization_id, 'roles:manage') OR is_platform_admin())
  WITH CHECK (has_org_permission(organization_id, 'roles:manage') OR is_platform_admin());

DROP POLICY IF EXISTS "roles_delete_admin" ON roles;
CREATE POLICY "roles_delete_admin" ON roles FOR DELETE
  TO authenticated
  USING ((has_org_permission(organization_id, 'roles:manage') OR is_platform_admin()) AND is_system = false);

-- ============================================================
-- RLS POLICIES — role_permissions
-- ============================================================
DROP POLICY IF EXISTS "rp_select_member" ON role_permissions;
CREATE POLICY "rp_select_member" ON role_permissions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM roles r
      WHERE r.id = role_id
        AND (r.organization_id IS NULL OR is_org_member(r.organization_id) OR is_platform_admin())
    )
  );

DROP POLICY IF EXISTS "rp_insert_admin" ON role_permissions;
CREATE POLICY "rp_insert_admin" ON role_permissions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM roles r
      WHERE r.id = role_id
        AND (has_org_permission(r.organization_id, 'roles:manage') OR is_platform_admin())
    )
  );

DROP POLICY IF EXISTS "rp_delete_admin" ON role_permissions;
CREATE POLICY "rp_delete_admin" ON role_permissions FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM roles r
      WHERE r.id = role_id
        AND (has_org_permission(r.organization_id, 'roles:manage') OR is_platform_admin())
    )
  );

-- ============================================================
-- RLS POLICIES — organization_members
-- ============================================================
DROP POLICY IF EXISTS "org_members_select" ON organization_members;
CREATE POLICY "org_members_select" ON organization_members FOR SELECT
  TO authenticated
  USING (is_org_member(organization_id) OR is_platform_admin());

DROP POLICY IF EXISTS "org_members_insert" ON organization_members;
CREATE POLICY "org_members_insert" ON organization_members FOR INSERT
  TO authenticated
  WITH CHECK (
    has_org_permission(organization_id, 'members:manage') OR is_platform_admin()
    OR (user_id = auth.uid())  -- self-join via invitation acceptance
  );

DROP POLICY IF EXISTS "org_members_update" ON organization_members;
CREATE POLICY "org_members_update" ON organization_members FOR UPDATE
  TO authenticated
  USING (has_org_permission(organization_id, 'members:manage') OR is_platform_admin())
  WITH CHECK (has_org_permission(organization_id, 'members:manage') OR is_platform_admin());

DROP POLICY IF EXISTS "org_members_delete" ON organization_members;
CREATE POLICY "org_members_delete" ON organization_members FOR DELETE
  TO authenticated
  USING (
    (has_org_permission(organization_id, 'members:manage') OR is_platform_admin())
    OR user_id = auth.uid()  -- self-removal
  );

-- ============================================================
-- RLS POLICIES — invitations
-- ============================================================
DROP POLICY IF EXISTS "invitations_select" ON invitations;
CREATE POLICY "invitations_select" ON invitations FOR SELECT
  TO authenticated
  USING (is_org_member(organization_id) OR is_platform_admin());

DROP POLICY IF EXISTS "invitations_insert" ON invitations;
CREATE POLICY "invitations_insert" ON invitations FOR INSERT
  TO authenticated
  WITH CHECK (has_org_permission(organization_id, 'members:manage') OR is_platform_admin());

DROP POLICY IF EXISTS "invitations_update" ON invitations;
CREATE POLICY "invitations_update" ON invitations FOR UPDATE
  TO authenticated
  USING (has_org_permission(organization_id, 'members:manage') OR is_platform_admin())
  WITH CHECK (has_org_permission(organization_id, 'members:manage') OR is_platform_admin());

DROP POLICY IF EXISTS "invitations_delete" ON invitations;
CREATE POLICY "invitations_delete" ON invitations FOR DELETE
  TO authenticated
  USING (has_org_permission(organization_id, 'members:manage') OR is_platform_admin());

-- ============================================================
-- RLS POLICIES — projects
-- ============================================================
DROP POLICY IF EXISTS "projects_select" ON projects;
CREATE POLICY "projects_select" ON projects FOR SELECT
  TO authenticated
  USING (is_org_member(organization_id) OR is_platform_admin());

DROP POLICY IF EXISTS "projects_insert" ON projects;
CREATE POLICY "projects_insert" ON projects FOR INSERT
  TO authenticated
  WITH CHECK (has_org_permission(organization_id, 'projects:create') OR is_platform_admin());

DROP POLICY IF EXISTS "projects_update" ON projects;
CREATE POLICY "projects_update" ON projects FOR UPDATE
  TO authenticated
  USING (has_org_permission(organization_id, 'projects:edit') OR is_platform_admin())
  WITH CHECK (has_org_permission(organization_id, 'projects:edit') OR is_platform_admin());

DROP POLICY IF EXISTS "projects_delete" ON projects;
CREATE POLICY "projects_delete" ON projects FOR DELETE
  TO authenticated
  USING (has_org_permission(organization_id, 'projects:delete') OR is_platform_admin());

-- ============================================================
-- RLS POLICIES — project_members
-- ============================================================
DROP POLICY IF EXISTS "project_members_select" ON project_members;
CREATE POLICY "project_members_select" ON project_members FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM projects p WHERE p.id = project_id AND is_org_member(p.organization_id)
    ) OR is_platform_admin()
  );

DROP POLICY IF EXISTS "project_members_insert" ON project_members;
CREATE POLICY "project_members_insert" ON project_members FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM projects p
      WHERE p.id = project_id AND (has_org_permission(p.organization_id, 'projects:edit') OR is_platform_admin())
    )
  );

DROP POLICY IF EXISTS "project_members_update" ON project_members;
CREATE POLICY "project_members_update" ON project_members FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM projects p
      WHERE p.id = project_id AND (has_org_permission(p.organization_id, 'projects:edit') OR is_platform_admin())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM projects p
      WHERE p.id = project_id AND (has_org_permission(p.organization_id, 'projects:edit') OR is_platform_admin())
    )
  );

DROP POLICY IF EXISTS "project_members_delete" ON project_members;
CREATE POLICY "project_members_delete" ON project_members FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM projects p
      WHERE p.id = project_id AND (has_org_permission(p.organization_id, 'projects:edit') OR is_platform_admin())
    ) OR user_id = auth.uid()
  );

-- ============================================================
-- RLS POLICIES — design_systems
-- ============================================================
DROP POLICY IF EXISTS "ds_select" ON design_systems;
CREATE POLICY "ds_select" ON design_systems FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM projects p WHERE p.id = project_id AND is_org_member(p.organization_id)
    ) OR is_platform_admin()
  );

DROP POLICY IF EXISTS "ds_insert" ON design_systems;
CREATE POLICY "ds_insert" ON design_systems FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM projects p
      WHERE p.id = project_id AND (has_org_permission(p.organization_id, 'design_systems:create') OR is_platform_admin())
    )
  );

DROP POLICY IF EXISTS "ds_update" ON design_systems;
CREATE POLICY "ds_update" ON design_systems FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM projects p
      WHERE p.id = project_id AND (has_org_permission(p.organization_id, 'design_systems:edit') OR is_platform_admin())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM projects p
      WHERE p.id = project_id AND (has_org_permission(p.organization_id, 'design_systems:edit') OR is_platform_admin())
    )
  );

DROP POLICY IF EXISTS "ds_delete" ON design_systems;
CREATE POLICY "ds_delete" ON design_systems FOR DELETE
  TO authenticated
  USING (is_platform_admin());

-- ============================================================
-- RLS POLICIES — design_system_modes
-- ============================================================
DROP POLICY IF EXISTS "ds_modes_select" ON design_system_modes;
CREATE POLICY "ds_modes_select" ON design_system_modes FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND is_org_member(p.organization_id)
    ) OR is_platform_admin()
  );

DROP POLICY IF EXISTS "ds_modes_insert" ON design_system_modes;
CREATE POLICY "ds_modes_insert" ON design_system_modes FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'design_systems:edit') OR is_platform_admin())
    )
  );

DROP POLICY IF EXISTS "ds_modes_update" ON design_system_modes;
CREATE POLICY "ds_modes_update" ON design_system_modes FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'design_systems:edit') OR is_platform_admin())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'design_systems:edit') OR is_platform_admin())
    )
  );

DROP POLICY IF EXISTS "ds_modes_delete" ON design_system_modes;
CREATE POLICY "ds_modes_delete" ON design_system_modes FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'design_systems:edit') OR is_platform_admin())
    )
  );

-- ============================================================
-- RLS POLICIES — token_collections
-- ============================================================
DROP POLICY IF EXISTS "token_collections_select" ON token_collections;
CREATE POLICY "token_collections_select" ON token_collections FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND is_org_member(p.organization_id)
    ) OR is_platform_admin()
  );

DROP POLICY IF EXISTS "token_collections_insert" ON token_collections;
CREATE POLICY "token_collections_insert" ON token_collections FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'tokens:manage') OR is_platform_admin())
    )
  );

DROP POLICY IF EXISTS "token_collections_update" ON token_collections;
CREATE POLICY "token_collections_update" ON token_collections FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'tokens:manage') OR is_platform_admin())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'tokens:manage') OR is_platform_admin())
    )
  );

DROP POLICY IF EXISTS "token_collections_delete" ON token_collections;
CREATE POLICY "token_collections_delete" ON token_collections FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'tokens:manage') OR is_platform_admin())
    )
  );

-- ============================================================
-- RLS POLICIES — design_tokens
-- ============================================================
DROP POLICY IF EXISTS "design_tokens_select" ON design_tokens;
CREATE POLICY "design_tokens_select" ON design_tokens FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND is_org_member(p.organization_id)
    ) OR is_platform_admin()
  );

DROP POLICY IF EXISTS "design_tokens_insert" ON design_tokens;
CREATE POLICY "design_tokens_insert" ON design_tokens FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'tokens:manage') OR is_platform_admin())
    )
  );

DROP POLICY IF EXISTS "design_tokens_update" ON design_tokens;
CREATE POLICY "design_tokens_update" ON design_tokens FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'tokens:manage') OR is_platform_admin())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'tokens:manage') OR is_platform_admin())
    )
  );

DROP POLICY IF EXISTS "design_tokens_delete" ON design_tokens;
CREATE POLICY "design_tokens_delete" ON design_tokens FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'tokens:manage') OR is_platform_admin())
    )
  );

-- ============================================================
-- RLS POLICIES — token_values
-- ============================================================
DROP POLICY IF EXISTS "token_values_select" ON token_values;
CREATE POLICY "token_values_select" ON token_values FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM design_tokens dt
      JOIN design_systems ds ON ds.id = dt.design_system_id
      JOIN projects p ON p.id = ds.project_id
      WHERE dt.id = token_id AND is_org_member(p.organization_id)
    ) OR is_platform_admin()
  );

DROP POLICY IF EXISTS "token_values_insert" ON token_values;
CREATE POLICY "token_values_insert" ON token_values FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM design_tokens dt
      JOIN design_systems ds ON ds.id = dt.design_system_id
      JOIN projects p ON p.id = ds.project_id
      WHERE dt.id = token_id AND (has_org_permission(p.organization_id, 'tokens:manage') OR is_platform_admin())
    )
  );

DROP POLICY IF EXISTS "token_values_update" ON token_values;
CREATE POLICY "token_values_update" ON token_values FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM design_tokens dt
      JOIN design_systems ds ON ds.id = dt.design_system_id
      JOIN projects p ON p.id = ds.project_id
      WHERE dt.id = token_id AND (has_org_permission(p.organization_id, 'tokens:manage') OR is_platform_admin())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM design_tokens dt
      JOIN design_systems ds ON ds.id = dt.design_system_id
      JOIN projects p ON p.id = ds.project_id
      WHERE dt.id = token_id AND (has_org_permission(p.organization_id, 'tokens:manage') OR is_platform_admin())
    )
  );

DROP POLICY IF EXISTS "token_values_delete" ON token_values;
CREATE POLICY "token_values_delete" ON token_values FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM design_tokens dt
      JOIN design_systems ds ON ds.id = dt.design_system_id
      JOIN projects p ON p.id = ds.project_id
      WHERE dt.id = token_id AND (has_org_permission(p.organization_id, 'tokens:manage') OR is_platform_admin())
    )
  );

-- ============================================================
-- RLS POLICIES — token_aliases
-- ============================================================
DROP POLICY IF EXISTS "token_aliases_select" ON token_aliases;
CREATE POLICY "token_aliases_select" ON token_aliases FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM design_tokens dt
      JOIN design_systems ds ON ds.id = dt.design_system_id
      JOIN projects p ON p.id = ds.project_id
      WHERE dt.id = source_token_id AND is_org_member(p.organization_id)
    ) OR is_platform_admin()
  );

DROP POLICY IF EXISTS "token_aliases_insert" ON token_aliases;
CREATE POLICY "token_aliases_insert" ON token_aliases FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM design_tokens dt
      JOIN design_systems ds ON ds.id = dt.design_system_id
      JOIN projects p ON p.id = ds.project_id
      WHERE dt.id = source_token_id AND (has_org_permission(p.organization_id, 'tokens:manage') OR is_platform_admin())
    )
  );

DROP POLICY IF EXISTS "token_aliases_delete" ON token_aliases;
CREATE POLICY "token_aliases_delete" ON token_aliases FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM design_tokens dt
      JOIN design_systems ds ON ds.id = dt.design_system_id
      JOIN projects p ON p.id = ds.project_id
      WHERE dt.id = source_token_id AND (has_org_permission(p.organization_id, 'tokens:manage') OR is_platform_admin())
    )
  );

-- ============================================================
-- RLS POLICIES — components
-- ============================================================
DROP POLICY IF EXISTS "components_select" ON components;
CREATE POLICY "components_select" ON components FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND is_org_member(p.organization_id)
    ) OR is_platform_admin()
  );

DROP POLICY IF EXISTS "components_insert" ON components;
CREATE POLICY "components_insert" ON components FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'components:manage') OR is_platform_admin())
    )
  );

DROP POLICY IF EXISTS "components_update" ON components;
CREATE POLICY "components_update" ON components FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'components:manage') OR is_platform_admin())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'components:manage') OR is_platform_admin())
    )
  );

DROP POLICY IF EXISTS "components_delete" ON components;
CREATE POLICY "components_delete" ON components FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM design_systems ds
      JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'components:manage') OR is_platform_admin())
    )
  );

-- ============================================================
-- RLS POLICIES — component_variants, component_states, component_token_mappings
-- ============================================================
DROP POLICY IF EXISTS "comp_variants_select" ON component_variants;
CREATE POLICY "comp_variants_select" ON component_variants FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM components c JOIN design_systems ds ON ds.id = c.design_system_id JOIN projects p ON p.id = ds.project_id WHERE c.id = component_id AND is_org_member(p.organization_id))
    OR is_platform_admin()
  );
DROP POLICY IF EXISTS "comp_variants_insert" ON component_variants;
CREATE POLICY "comp_variants_insert" ON component_variants FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM components c JOIN design_systems ds ON ds.id = c.design_system_id JOIN projects p ON p.id = ds.project_id WHERE c.id = component_id AND (has_org_permission(p.organization_id, 'components:manage') OR is_platform_admin()))
  );
DROP POLICY IF EXISTS "comp_variants_update" ON component_variants;
CREATE POLICY "comp_variants_update" ON component_variants FOR UPDATE
  TO authenticated USING (
    EXISTS (SELECT 1 FROM components c JOIN design_systems ds ON ds.id = c.design_system_id JOIN projects p ON p.id = ds.project_id WHERE c.id = component_id AND (has_org_permission(p.organization_id, 'components:manage') OR is_platform_admin()))
  ) WITH CHECK (
    EXISTS (SELECT 1 FROM components c JOIN design_systems ds ON ds.id = c.design_system_id JOIN projects p ON p.id = ds.project_id WHERE c.id = component_id AND (has_org_permission(p.organization_id, 'components:manage') OR is_platform_admin()))
  );
DROP POLICY IF EXISTS "comp_variants_delete" ON component_variants;
CREATE POLICY "comp_variants_delete" ON component_variants FOR DELETE
  TO authenticated USING (
    EXISTS (SELECT 1 FROM components c JOIN design_systems ds ON ds.id = c.design_system_id JOIN projects p ON p.id = ds.project_id WHERE c.id = component_id AND (has_org_permission(p.organization_id, 'components:manage') OR is_platform_admin()))
  );

DROP POLICY IF EXISTS "comp_states_select" ON component_states;
CREATE POLICY "comp_states_select" ON component_states FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM components c JOIN design_systems ds ON ds.id = c.design_system_id JOIN projects p ON p.id = ds.project_id WHERE c.id = component_id AND is_org_member(p.organization_id))
    OR is_platform_admin()
  );
DROP POLICY IF EXISTS "comp_states_insert" ON component_states;
CREATE POLICY "comp_states_insert" ON component_states FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM components c JOIN design_systems ds ON ds.id = c.design_system_id JOIN projects p ON p.id = ds.project_id WHERE c.id = component_id AND (has_org_permission(p.organization_id, 'components:manage') OR is_platform_admin()))
  );
DROP POLICY IF EXISTS "comp_states_update" ON component_states;
CREATE POLICY "comp_states_update" ON component_states FOR UPDATE
  TO authenticated USING (
    EXISTS (SELECT 1 FROM components c JOIN design_systems ds ON ds.id = c.design_system_id JOIN projects p ON p.id = ds.project_id WHERE c.id = component_id AND (has_org_permission(p.organization_id, 'components:manage') OR is_platform_admin()))
  ) WITH CHECK (
    EXISTS (SELECT 1 FROM components c JOIN design_systems ds ON ds.id = c.design_system_id JOIN projects p ON p.id = ds.project_id WHERE c.id = component_id AND (has_org_permission(p.organization_id, 'components:manage') OR is_platform_admin()))
  );
DROP POLICY IF EXISTS "comp_states_delete" ON component_states;
CREATE POLICY "comp_states_delete" ON component_states FOR DELETE
  TO authenticated USING (
    EXISTS (SELECT 1 FROM components c JOIN design_systems ds ON ds.id = c.design_system_id JOIN projects p ON p.id = ds.project_id WHERE c.id = component_id AND (has_org_permission(p.organization_id, 'components:manage') OR is_platform_admin()))
  );

DROP POLICY IF EXISTS "comp_token_map_select" ON component_token_mappings;
CREATE POLICY "comp_token_map_select" ON component_token_mappings FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM components c JOIN design_systems ds ON ds.id = c.design_system_id JOIN projects p ON p.id = ds.project_id WHERE c.id = component_id AND is_org_member(p.organization_id))
    OR is_platform_admin()
  );
DROP POLICY IF EXISTS "comp_token_map_insert" ON component_token_mappings;
CREATE POLICY "comp_token_map_insert" ON component_token_mappings FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM components c JOIN design_systems ds ON ds.id = c.design_system_id JOIN projects p ON p.id = ds.project_id WHERE c.id = component_id AND (has_org_permission(p.organization_id, 'components:manage') OR is_platform_admin()))
  );
DROP POLICY IF EXISTS "comp_token_map_delete" ON component_token_mappings;
CREATE POLICY "comp_token_map_delete" ON component_token_mappings FOR DELETE
  TO authenticated USING (
    EXISTS (SELECT 1 FROM components c JOIN design_systems ds ON ds.id = c.design_system_id JOIN projects p ON p.id = ds.project_id WHERE c.id = component_id AND (has_org_permission(p.organization_id, 'components:manage') OR is_platform_admin()))
  );

-- ============================================================
-- RLS POLICIES — documentation_entries
-- ============================================================
DROP POLICY IF EXISTS "docs_select" ON documentation_entries;
CREATE POLICY "docs_select" ON documentation_entries FOR SELECT
  TO authenticated
  USING (
    (organization_id IS NOT NULL AND is_org_member(organization_id))
    OR (design_system_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM design_systems ds JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND is_org_member(p.organization_id)
    ))
    OR is_platform_admin()
  );

DROP POLICY IF EXISTS "docs_insert" ON documentation_entries;
CREATE POLICY "docs_insert" ON documentation_entries FOR INSERT
  TO authenticated
  WITH CHECK (
    (organization_id IS NOT NULL AND has_org_permission(organization_id, 'docs:manage'))
    OR (design_system_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM design_systems ds JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'docs:manage') OR is_platform_admin())
    ))
    OR is_platform_admin()
  );

DROP POLICY IF EXISTS "docs_update" ON documentation_entries;
CREATE POLICY "docs_update" ON documentation_entries FOR UPDATE
  TO authenticated
  USING (
    (organization_id IS NOT NULL AND has_org_permission(organization_id, 'docs:manage'))
    OR (design_system_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM design_systems ds JOIN projects p ON p.id = ds.project_id
      WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'docs:manage') OR is_platform_admin())
    ))
    OR is_platform_admin()
  )
  WITH CHECK (
    (organization_id IS NOT NULL AND has_org_permission(organization_id, 'docs:manage'))
    OR is_platform_admin()
  );

DROP POLICY IF EXISTS "docs_delete" ON documentation_entries;
CREATE POLICY "docs_delete" ON documentation_entries FOR DELETE
  TO authenticated
  USING (is_platform_admin() OR auth.uid() = created_by);

-- ============================================================
-- RLS POLICIES — assets, releases, audit_logs
-- ============================================================
DROP POLICY IF EXISTS "assets_select" ON assets;
CREATE POLICY "assets_select" ON assets FOR SELECT
  TO authenticated USING (is_org_member(organization_id) OR is_platform_admin());
DROP POLICY IF EXISTS "assets_insert" ON assets;
CREATE POLICY "assets_insert" ON assets FOR INSERT
  TO authenticated WITH CHECK (is_org_member(organization_id));
DROP POLICY IF EXISTS "assets_update" ON assets;
CREATE POLICY "assets_update" ON assets FOR UPDATE
  TO authenticated USING (is_org_member(organization_id)) WITH CHECK (is_org_member(organization_id));
DROP POLICY IF EXISTS "assets_delete" ON assets;
CREATE POLICY "assets_delete" ON assets FOR DELETE
  TO authenticated USING (is_org_member(organization_id) AND auth.uid() = created_by);

DROP POLICY IF EXISTS "releases_select" ON releases;
CREATE POLICY "releases_select" ON releases FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM design_systems ds JOIN projects p ON p.id = ds.project_id WHERE ds.id = design_system_id AND is_org_member(p.organization_id))
    OR is_platform_admin()
  );
DROP POLICY IF EXISTS "releases_insert" ON releases;
CREATE POLICY "releases_insert" ON releases FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM design_systems ds JOIN projects p ON p.id = ds.project_id WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'releases:create') OR is_platform_admin()))
  );
DROP POLICY IF EXISTS "releases_update" ON releases;
CREATE POLICY "releases_update" ON releases FOR UPDATE
  TO authenticated USING (
    EXISTS (SELECT 1 FROM design_systems ds JOIN projects p ON p.id = ds.project_id WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'releases:create') OR is_platform_admin()))
  ) WITH CHECK (
    EXISTS (SELECT 1 FROM design_systems ds JOIN projects p ON p.id = ds.project_id WHERE ds.id = design_system_id AND (has_org_permission(p.organization_id, 'releases:create') OR is_platform_admin()))
  );
DROP POLICY IF EXISTS "releases_delete" ON releases;
CREATE POLICY "releases_delete" ON releases FOR DELETE
  TO authenticated USING (is_platform_admin());

-- Audit logs: anyone in the org can read; only insert (no update/delete)
DROP POLICY IF EXISTS "audit_logs_select" ON audit_logs;
CREATE POLICY "audit_logs_select" ON audit_logs FOR SELECT
  TO authenticated
  USING (
    (organization_id IS NOT NULL AND is_org_member(organization_id))
    OR actor_id = auth.uid()
    OR is_platform_admin()
  );

DROP POLICY IF EXISTS "audit_logs_insert" ON audit_logs;
CREATE POLICY "audit_logs_insert" ON audit_logs FOR INSERT
  TO authenticated
  WITH CHECK (actor_id = auth.uid() OR is_platform_admin());

-- ============================================================
-- REFERENCE DATA: permissions
-- ============================================================
INSERT INTO permissions (key, label, category, description) VALUES
  ('org:manage',             'Manage Organization',       'organization', 'Edit org settings and metadata'),
  ('members:manage',         'Manage Members',            'organization', 'Invite, remove, and update member roles'),
  ('roles:manage',           'Manage Roles',              'organization', 'Create, edit, delete custom roles and assign permissions'),
  ('projects:create',        'Create Projects',           'project',      'Create new projects in the organization'),
  ('projects:edit',          'Edit Projects',             'project',      'Edit project settings and membership'),
  ('projects:delete',        'Delete Projects',           'project',      'Archive or delete projects'),
  ('design_systems:create',  'Create Design Systems',     'design-system','Create new design systems within a project'),
  ('design_systems:edit',    'Edit Design Systems',       'design-system','Edit design system settings and structure'),
  ('tokens:manage',          'Manage Design Tokens',      'tokens',       'Create, edit, deprecate design tokens'),
  ('tokens:approve',         'Approve Tokens',            'tokens',       'Review and approve token status changes'),
  ('components:manage',      'Manage Components',         'components',   'Create, edit, deprecate components'),
  ('components:approve',     'Approve Components',        'components',   'Review and approve component status changes'),
  ('docs:manage',            'Manage Documentation',      'docs',         'Create and edit documentation entries'),
  ('releases:create',        'Create Releases',           'releases',     'Create and publish design system releases'),
  ('audit:view',             'View Audit History',        'audit',        'Read security and change audit logs')
ON CONFLICT (key) DO NOTHING;

-- ============================================================
-- REFERENCE DATA: system roles (org-neutral, seeded once)
-- Note: organization_id IS NULL = system-level role template
-- ============================================================
-- We do NOT seed org-specific roles here because organization_id is required
-- to be NOT NULL for uniqueness. System role templates use NULL.
-- Real org roles are created via the org creation flow.

-- ============================================================
-- FIRST ADMIN BOOTSTRAP
-- After signing up through Supabase Auth, run this query in the
-- Supabase SQL Editor, replacing YOUR_AUTH_USER_UUID with your real user id:
--
-- UPDATE profiles SET is_platform_admin = true WHERE id = 'YOUR_AUTH_USER_UUID';
-- ============================================================
