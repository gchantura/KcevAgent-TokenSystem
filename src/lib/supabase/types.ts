import type { Database } from './database.types';

export type Tables<T extends keyof Database['public']['Tables']> =
  Database['public']['Tables'][T]['Row'];

export type InsertTables<T extends keyof Database['public']['Tables']> =
  Database['public']['Tables'][T]['Insert'];

export type UpdateTables<T extends keyof Database['public']['Tables']> =
  Database['public']['Tables'][T]['Update'];

export type Profile = Tables<'profiles'>;
export type Organization = Tables<'organizations'>;
export type Role = Tables<'roles'>;
export type Permission = Tables<'permissions'>;
export type RolePermission = Tables<'role_permissions'>;
export type OrganizationMember = Tables<'organization_members'>;
export type Invitation = Tables<'invitations'>;
export type Project = Tables<'projects'>;
export type DesignSystem = Tables<'design_systems'>;
export type DesignSystemMode = Tables<'design_system_modes'>;
export type TokenCollection = Tables<'token_collections'>;
export type DesignToken = Tables<'design_tokens'>;
export type TokenValue = Tables<'token_values'>;
export type Component = Tables<'components'>;
export type ComponentVariant = Tables<'component_variants'>;
export type ComponentState = Tables<'component_states'>;
export type ComponentTokenMapping = Tables<'component_token_mappings'>;
export type DocumentationEntry = Tables<'documentation_entries'>;
export type Release = Tables<'releases'>;
export type AuditLog = Tables<'audit_logs'>;

export type MaturityStatus = 'draft' | 'review' | 'approved' | 'deprecated';
export type TokenType = 'color' | 'typography' | 'spacing' | 'sizing' | 'border' | 'shadow' | 'opacity' | 'duration' | 'easing' | 'z-index' | 'other';
export type TokenTier = 'primitive' | 'semantic' | 'component' | 'custom';
export type ComponentStatus = 'draft' | 'review' | 'approved' | 'deprecated' | 'needs-update';
