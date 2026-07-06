export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export type Database = {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          display_name: string | null;
          avatar_url: string | null;
          bio: string | null;
          status: 'active' | 'suspended' | 'pending';
          is_platform_admin: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id: string;
          display_name?: string | null;
          avatar_url?: string | null;
          bio?: string | null;
          status?: 'active' | 'suspended' | 'pending';
          is_platform_admin?: boolean;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          display_name?: string | null;
          avatar_url?: string | null;
          bio?: string | null;
          status?: 'active' | 'suspended' | 'pending';
          is_platform_admin?: boolean;
          updated_at?: string;
        };
      };
      organizations: {
        Row: {
          id: string;
          name: string;
          slug: string;
          description: string | null;
          logo_url: string | null;
          settings: Json;
          status: 'active' | 'archived' | 'suspended';
          created_by: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          name: string;
          slug: string;
          description?: string | null;
          logo_url?: string | null;
          settings?: Json;
          status?: 'active' | 'archived' | 'suspended';
          created_by?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          name?: string;
          slug?: string;
          description?: string | null;
          logo_url?: string | null;
          settings?: Json;
          status?: 'active' | 'archived' | 'suspended';
          updated_at?: string;
        };
      };
      roles: {
        Row: {
          id: string;
          organization_id: string | null;
          name: string;
          slug: string;
          description: string | null;
          is_system: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          organization_id?: string | null;
          name: string;
          slug: string;
          description?: string | null;
          is_system?: boolean;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          name?: string;
          slug?: string;
          description?: string | null;
          updated_at?: string;
        };
      };
      permissions: {
        Row: {
          id: string;
          key: string;
          label: string;
          description: string | null;
          category: string;
          created_at: string;
        };
        Insert: {
          id?: string;
          key: string;
          label: string;
          description?: string | null;
          category?: string;
          created_at?: string;
        };
        Update: {
          label?: string;
          description?: string | null;
          category?: string;
        };
      };
      role_permissions: {
        Row: {
          role_id: string;
          permission_id: string;
          granted_at: string;
          granted_by: string | null;
        };
        Insert: {
          role_id: string;
          permission_id: string;
          granted_at?: string;
          granted_by?: string | null;
        };
        Update: Record<string, never>;
      };
      organization_members: {
        Row: {
          id: string;
          organization_id: string;
          user_id: string;
          role_id: string;
          status: 'active' | 'suspended' | 'removed';
          joined_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          organization_id: string;
          user_id: string;
          role_id: string;
          status?: 'active' | 'suspended' | 'removed';
          joined_at?: string;
          updated_at?: string;
        };
        Update: {
          role_id?: string;
          status?: 'active' | 'suspended' | 'removed';
          updated_at?: string;
        };
      };
      invitations: {
        Row: {
          id: string;
          organization_id: string;
          email: string;
          role_id: string;
          status: 'pending' | 'accepted' | 'declined' | 'expired';
          token: string;
          invited_by: string | null;
          expires_at: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          organization_id: string;
          email: string;
          role_id: string;
          status?: 'pending' | 'accepted' | 'declined' | 'expired';
          token?: string;
          invited_by?: string | null;
          expires_at?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          status?: 'pending' | 'accepted' | 'declined' | 'expired';
          updated_at?: string;
        };
      };
      projects: {
        Row: {
          id: string;
          organization_id: string;
          name: string;
          slug: string;
          description: string | null;
          status: 'active' | 'archived';
          created_by: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          organization_id: string;
          name: string;
          slug: string;
          description?: string | null;
          status?: 'active' | 'archived';
          created_by?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          name?: string;
          slug?: string;
          description?: string | null;
          status?: 'active' | 'archived';
          updated_at?: string;
        };
      };
      design_systems: {
        Row: {
          id: string;
          project_id: string;
          name: string;
          description: string | null;
          version: string;
          maturity: 'draft' | 'review' | 'approved' | 'deprecated';
          settings: Json;
          created_by: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          project_id: string;
          name: string;
          description?: string | null;
          version?: string;
          maturity?: 'draft' | 'review' | 'approved' | 'deprecated';
          settings?: Json;
          created_by?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          name?: string;
          description?: string | null;
          version?: string;
          maturity?: 'draft' | 'review' | 'approved' | 'deprecated';
          settings?: Json;
          updated_at?: string;
        };
      };
      design_system_modes: {
        Row: {
          id: string;
          design_system_id: string;
          name: string;
          slug: string;
          description: string | null;
          is_default: boolean;
          created_at: string;
        };
        Insert: {
          id?: string;
          design_system_id: string;
          name: string;
          slug: string;
          description?: string | null;
          is_default?: boolean;
          created_at?: string;
        };
        Update: {
          name?: string;
          slug?: string;
          description?: string | null;
          is_default?: boolean;
        };
      };
      token_collections: {
        Row: {
          id: string;
          design_system_id: string;
          name: string;
          slug: string;
          tier: 'primitive' | 'semantic' | 'component' | 'custom';
          description: string | null;
          sort_order: number;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          design_system_id: string;
          name: string;
          slug: string;
          tier?: 'primitive' | 'semantic' | 'component' | 'custom';
          description?: string | null;
          sort_order?: number;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          name?: string;
          slug?: string;
          tier?: 'primitive' | 'semantic' | 'component' | 'custom';
          description?: string | null;
          sort_order?: number;
          updated_at?: string;
        };
      };
      design_tokens: {
        Row: {
          id: string;
          design_system_id: string;
          collection_id: string;
          name: string;
          path: string;
          token_type: 'color' | 'typography' | 'spacing' | 'sizing' | 'border' | 'shadow' | 'opacity' | 'duration' | 'easing' | 'z-index' | 'other';
          description: string | null;
          usage_guidance: string | null;
          status: 'draft' | 'active' | 'deprecated' | 'archived';
          is_alias: boolean;
          alias_target_id: string | null;
          created_by: string | null;
          updated_by: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          design_system_id: string;
          collection_id: string;
          name: string;
          path: string;
          token_type: 'color' | 'typography' | 'spacing' | 'sizing' | 'border' | 'shadow' | 'opacity' | 'duration' | 'easing' | 'z-index' | 'other';
          description?: string | null;
          usage_guidance?: string | null;
          status?: 'draft' | 'active' | 'deprecated' | 'archived';
          is_alias?: boolean;
          alias_target_id?: string | null;
          created_by?: string | null;
          updated_by?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          name?: string;
          path?: string;
          token_type?: 'color' | 'typography' | 'spacing' | 'sizing' | 'border' | 'shadow' | 'opacity' | 'duration' | 'easing' | 'z-index' | 'other';
          description?: string | null;
          usage_guidance?: string | null;
          status?: 'draft' | 'active' | 'deprecated' | 'archived';
          is_alias?: boolean;
          alias_target_id?: string | null;
          updated_by?: string | null;
          updated_at?: string;
        };
      };
      token_values: {
        Row: {
          id: string;
          token_id: string;
          mode_id: string | null;
          raw_value: string;
          resolved_value: string | null;
          value_type: 'literal' | 'alias' | 'computed';
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          token_id: string;
          mode_id?: string | null;
          raw_value: string;
          resolved_value?: string | null;
          value_type?: 'literal' | 'alias' | 'computed';
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          raw_value?: string;
          resolved_value?: string | null;
          value_type?: 'literal' | 'alias' | 'computed';
          updated_at?: string;
        };
      };
      components: {
        Row: {
          id: string;
          design_system_id: string;
          name: string;
          slug: string;
          category: string;
          description: string | null;
          usage_guidance: string | null;
          accessibility_guidance: string | null;
          code_reference: string | null;
          status: 'draft' | 'review' | 'approved' | 'deprecated' | 'needs-update';
          maturity: 'draft' | 'review' | 'approved' | 'deprecated';
          created_by: string | null;
          updated_by: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          design_system_id: string;
          name: string;
          slug: string;
          category?: string;
          description?: string | null;
          usage_guidance?: string | null;
          accessibility_guidance?: string | null;
          code_reference?: string | null;
          status?: 'draft' | 'review' | 'approved' | 'deprecated' | 'needs-update';
          maturity?: 'draft' | 'review' | 'approved' | 'deprecated';
          created_by?: string | null;
          updated_by?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          name?: string;
          slug?: string;
          category?: string;
          description?: string | null;
          usage_guidance?: string | null;
          accessibility_guidance?: string | null;
          code_reference?: string | null;
          status?: 'draft' | 'review' | 'approved' | 'deprecated' | 'needs-update';
          maturity?: 'draft' | 'review' | 'approved' | 'deprecated';
          updated_by?: string | null;
          updated_at?: string;
        };
      };
      component_variants: {
        Row: {
          id: string;
          component_id: string;
          name: string;
          slug: string;
          description: string | null;
          properties: Json;
          created_at: string;
        };
        Insert: {
          id?: string;
          component_id: string;
          name: string;
          slug: string;
          description?: string | null;
          properties?: Json;
          created_at?: string;
        };
        Update: {
          name?: string;
          slug?: string;
          description?: string | null;
          properties?: Json;
        };
      };
      component_states: {
        Row: {
          id: string;
          component_id: string;
          name: string;
          slug: string;
          description: string | null;
        };
        Insert: {
          id?: string;
          component_id: string;
          name: string;
          slug: string;
          description?: string | null;
        };
        Update: {
          name?: string;
          slug?: string;
          description?: string | null;
        };
      };
      component_token_mappings: {
        Row: {
          id: string;
          component_id: string;
          variant_id: string | null;
          state_id: string | null;
          token_id: string;
          css_property: string;
          description: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          component_id: string;
          variant_id?: string | null;
          state_id?: string | null;
          token_id: string;
          css_property: string;
          description?: string | null;
          created_at?: string;
        };
        Update: {
          css_property?: string;
          description?: string | null;
        };
      };
      documentation_entries: {
        Row: {
          id: string;
          organization_id: string | null;
          project_id: string | null;
          design_system_id: string | null;
          component_id: string | null;
          token_id: string | null;
          title: string;
          content: string;
          doc_type: string;
          status: 'draft' | 'published' | 'archived';
          created_by: string | null;
          updated_by: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          organization_id?: string | null;
          project_id?: string | null;
          design_system_id?: string | null;
          component_id?: string | null;
          token_id?: string | null;
          title: string;
          content?: string;
          doc_type?: string;
          status?: 'draft' | 'published' | 'archived';
          created_by?: string | null;
          updated_by?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          title?: string;
          content?: string;
          doc_type?: string;
          status?: 'draft' | 'published' | 'archived';
          updated_by?: string | null;
          updated_at?: string;
        };
      };
      releases: {
        Row: {
          id: string;
          design_system_id: string;
          version: string;
          name: string | null;
          description: string | null;
          status: 'draft' | 'published' | 'deprecated';
          published_by: string | null;
          published_at: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          design_system_id: string;
          version: string;
          name?: string | null;
          description?: string | null;
          status?: 'draft' | 'published' | 'deprecated';
          published_by?: string | null;
          published_at?: string | null;
          created_at?: string;
        };
        Update: {
          version?: string;
          name?: string | null;
          description?: string | null;
          status?: 'draft' | 'published' | 'deprecated';
          published_by?: string | null;
          published_at?: string | null;
        };
      };
      audit_logs: {
        Row: {
          id: string;
          organization_id: string | null;
          actor_id: string | null;
          action: string;
          resource_type: string;
          resource_id: string | null;
          metadata: Json;
          created_at: string;
        };
        Insert: {
          id?: string;
          organization_id?: string | null;
          actor_id?: string | null;
          action: string;
          resource_type: string;
          resource_id?: string | null;
          metadata?: Json;
          created_at?: string;
        };
        Update: Record<string, never>;
      };
    };
    Views: Record<string, never>;
    Functions: {
      is_org_member: {
        Args: { org_id: string; uid?: string };
        Returns: boolean;
      };
      has_org_permission: {
        Args: { org_id: string; perm_key: string; uid?: string };
        Returns: boolean;
      };
      is_platform_admin: {
        Args: { uid?: string };
        Returns: boolean;
      };
      get_org_role_slug: {
        Args: { org_id: string; uid?: string };
        Returns: string;
      };
    };
    Enums: Record<string, never>;
  };
};
