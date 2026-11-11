--
-- PostgreSQL database dump
--

\restrict lHUUhxSKlE6pcheRGMS2mg8KDSk96aZGzoKjrW5V1GmpqhaBRf64EpmEemtUrbO

-- Dumped from database version 16.15 (Debian 16.15-1.pgdg13+2)
-- Dumped by pg_dump version 16.15 (Debian 16.15-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: set_slug_from_name(); Type: FUNCTION; Schema: public; Owner: abroad
--

CREATE FUNCTION public.set_slug_from_name() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
  base text;
  candidate text;
  n integer DEFAULT 1;
  taken boolean;
BEGIN
  -- A slug that was typed by a person: just tidy it (lowercase, hyphens).
  IF NEW.slug IS NOT NULL THEN
    NEW.slug = slugify_text(NEW.slug);
  END IF;
  IF NEW.slug IS NOT NULL AND NEW.slug <> '' THEN
    RETURN NEW;
  END IF;

  -- Slug left empty: build it from the name.
  base = slugify_text(NEW.name);
  IF base = '' THEN
    RAISE EXCEPTION 'Cannot create a slug: the name needs at least one letter or number';
  END IF;

  -- Make it unique: data-science, data-science-2, data-science-3 ...
  candidate = base;
  LOOP
    EXECUTE 'SELECT EXISTS (SELECT 1 FROM ' || quote_ident(TG_TABLE_NAME)
         || ' WHERE slug = $1 AND id <> $2)'
      INTO taken
      USING candidate, COALESCE(NEW.id, CAST('00000000-0000-0000-0000-000000000000' AS uuid));
    EXIT WHEN NOT taken;
    n = n + 1;
    candidate = base || '-' || n;
  END LOOP;

  NEW.slug = candidate;
  RETURN NEW;
END
$_$;


ALTER FUNCTION public.set_slug_from_name() OWNER TO abroad;

--
-- Name: slugify_text(text); Type: FUNCTION; Schema: public; Owner: abroad
--

CREATE FUNCTION public.slugify_text(txt text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
  SELECT btrim(
    regexp_replace(
      lower(replace(replace(coalesce(txt, ''), '&', ' '), '''', '')),
      '[^a-z0-9]+', '-', 'g'),
    '-')
$$;


ALTER FUNCTION public.slugify_text(txt text) OWNER TO abroad;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO abroad;

--
-- Name: countries; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.countries (
    id uuid NOT NULL,
    name character varying(150) NOT NULL,
    slug character varying(180) NOT NULL,
    country_code character varying(3),
    description text,
    status character varying(30) DEFAULT 'draft'::character varying NOT NULL,
    display_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    CONSTRAINT ck_countries_status CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'pending_review'::character varying, 'published'::character varying, 'archived'::character varying])::text[])))
);


ALTER TABLE public.countries OWNER TO abroad;

--
-- Name: directus_access; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_access (
    id uuid NOT NULL,
    role uuid,
    "user" uuid,
    policy uuid NOT NULL,
    sort integer
);


ALTER TABLE public.directus_access OWNER TO abroad;

--
-- Name: directus_activity; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_activity (
    id integer NOT NULL,
    action character varying(45) NOT NULL,
    "user" uuid,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ip character varying(50),
    user_agent text,
    collection character varying(64) NOT NULL,
    item character varying(255) NOT NULL,
    origin character varying(255)
);


ALTER TABLE public.directus_activity OWNER TO abroad;

--
-- Name: directus_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: abroad
--

CREATE SEQUENCE public.directus_activity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.directus_activity_id_seq OWNER TO abroad;

--
-- Name: directus_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: abroad
--

ALTER SEQUENCE public.directus_activity_id_seq OWNED BY public.directus_activity.id;


--
-- Name: directus_collections; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_collections (
    collection character varying(64) NOT NULL,
    icon character varying(64),
    note text,
    display_template character varying(255),
    hidden boolean DEFAULT false NOT NULL,
    singleton boolean DEFAULT false NOT NULL,
    translations json,
    archive_field character varying(64),
    archive_app_filter boolean DEFAULT true NOT NULL,
    archive_value character varying(255),
    unarchive_value character varying(255),
    sort_field character varying(64),
    accountability character varying(255) DEFAULT 'all'::character varying,
    color character varying(255),
    item_duplication_fields json,
    sort integer,
    "group" character varying(64),
    collapse character varying(255) DEFAULT 'open'::character varying NOT NULL,
    preview_url character varying(255),
    versioning boolean DEFAULT false NOT NULL
);


ALTER TABLE public.directus_collections OWNER TO abroad;

--
-- Name: directus_comments; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_comments (
    id uuid NOT NULL,
    collection character varying(64) NOT NULL,
    item character varying(255) NOT NULL,
    comment text NOT NULL,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    date_updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid,
    user_updated uuid
);


ALTER TABLE public.directus_comments OWNER TO abroad;

--
-- Name: directus_dashboards; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_dashboards (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    icon character varying(64) DEFAULT 'dashboard'::character varying NOT NULL,
    note text,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid,
    color character varying(255)
);


ALTER TABLE public.directus_dashboards OWNER TO abroad;

--
-- Name: directus_deployment_projects; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_deployment_projects (
    id uuid NOT NULL,
    deployment uuid NOT NULL,
    external_id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid,
    url character varying(255),
    framework character varying(255),
    deployable boolean DEFAULT true NOT NULL
);


ALTER TABLE public.directus_deployment_projects OWNER TO abroad;

--
-- Name: directus_deployment_runs; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_deployment_runs (
    id uuid NOT NULL,
    project uuid NOT NULL,
    external_id character varying(255) NOT NULL,
    target character varying(255) NOT NULL,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid,
    status character varying(255),
    url character varying(255),
    started_at timestamp with time zone,
    completed_at timestamp with time zone
);


ALTER TABLE public.directus_deployment_runs OWNER TO abroad;

--
-- Name: directus_deployments; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_deployments (
    id uuid NOT NULL,
    provider character varying(255) NOT NULL,
    credentials text,
    options text,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid,
    webhook_ids json,
    webhook_secret character varying(255),
    last_synced_at timestamp with time zone
);


ALTER TABLE public.directus_deployments OWNER TO abroad;

--
-- Name: directus_extensions; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_extensions (
    enabled boolean DEFAULT true NOT NULL,
    id uuid NOT NULL,
    folder character varying(255) NOT NULL,
    source character varying(255) NOT NULL,
    bundle uuid
);


ALTER TABLE public.directus_extensions OWNER TO abroad;

--
-- Name: directus_fields; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_fields (
    id integer NOT NULL,
    collection character varying(64) NOT NULL,
    field character varying(64) NOT NULL,
    special character varying(64),
    interface character varying(64),
    options json,
    display character varying(64),
    display_options json,
    readonly boolean DEFAULT false NOT NULL,
    hidden boolean DEFAULT false NOT NULL,
    sort integer,
    width character varying(30) DEFAULT 'full'::character varying,
    translations json,
    note text,
    conditions json,
    required boolean DEFAULT false,
    "group" character varying(64),
    validation json,
    validation_message text,
    searchable boolean DEFAULT true NOT NULL
);


ALTER TABLE public.directus_fields OWNER TO abroad;

--
-- Name: directus_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: abroad
--

CREATE SEQUENCE public.directus_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.directus_fields_id_seq OWNER TO abroad;

--
-- Name: directus_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: abroad
--

ALTER SEQUENCE public.directus_fields_id_seq OWNED BY public.directus_fields.id;


--
-- Name: directus_files; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_files (
    id uuid NOT NULL,
    storage character varying(255) NOT NULL,
    filename_disk character varying(255),
    filename_download character varying(255) NOT NULL,
    title character varying(255),
    type character varying(255),
    folder uuid,
    uploaded_by uuid,
    created_on timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_by uuid,
    modified_on timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    charset character varying(50),
    filesize bigint,
    width integer,
    height integer,
    duration integer,
    embed character varying(200),
    description text,
    location text,
    tags text,
    metadata json,
    focal_point_x integer,
    focal_point_y integer,
    tus_id character varying(64),
    tus_data json,
    uploaded_on timestamp with time zone
);


ALTER TABLE public.directus_files OWNER TO abroad;

--
-- Name: directus_flows; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_flows (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    icon character varying(64),
    color character varying(255),
    description text,
    status character varying(255) DEFAULT 'active'::character varying NOT NULL,
    trigger character varying(255),
    accountability character varying(255) DEFAULT 'all'::character varying,
    options json,
    operation uuid,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid
);


ALTER TABLE public.directus_flows OWNER TO abroad;

--
-- Name: directus_folders; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_folders (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    parent uuid
);


ALTER TABLE public.directus_folders OWNER TO abroad;

--
-- Name: directus_migrations; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_migrations (
    version character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.directus_migrations OWNER TO abroad;

--
-- Name: directus_notifications; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_notifications (
    id integer NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(255) DEFAULT 'inbox'::character varying,
    recipient uuid NOT NULL,
    sender uuid,
    subject character varying(255) NOT NULL,
    message text,
    collection character varying(64),
    item character varying(255)
);


ALTER TABLE public.directus_notifications OWNER TO abroad;

--
-- Name: directus_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: abroad
--

CREATE SEQUENCE public.directus_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.directus_notifications_id_seq OWNER TO abroad;

--
-- Name: directus_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: abroad
--

ALTER SEQUENCE public.directus_notifications_id_seq OWNED BY public.directus_notifications.id;


--
-- Name: directus_operations; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_operations (
    id uuid NOT NULL,
    name character varying(255),
    key character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    position_x integer NOT NULL,
    position_y integer NOT NULL,
    options json,
    resolve uuid,
    reject uuid,
    flow uuid NOT NULL,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid
);


ALTER TABLE public.directus_operations OWNER TO abroad;

--
-- Name: directus_panels; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_panels (
    id uuid NOT NULL,
    dashboard uuid NOT NULL,
    name character varying(255),
    icon character varying(64) DEFAULT NULL::character varying,
    color character varying(10),
    show_header boolean DEFAULT false NOT NULL,
    note text,
    type character varying(255) NOT NULL,
    position_x integer NOT NULL,
    position_y integer NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    options json,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid
);


ALTER TABLE public.directus_panels OWNER TO abroad;

--
-- Name: directus_permissions; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_permissions (
    id integer NOT NULL,
    collection character varying(64) NOT NULL,
    action character varying(10) NOT NULL,
    permissions json,
    validation json,
    presets json,
    fields text,
    policy uuid NOT NULL
);


ALTER TABLE public.directus_permissions OWNER TO abroad;

--
-- Name: directus_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: abroad
--

CREATE SEQUENCE public.directus_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.directus_permissions_id_seq OWNER TO abroad;

--
-- Name: directus_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: abroad
--

ALTER SEQUENCE public.directus_permissions_id_seq OWNED BY public.directus_permissions.id;


--
-- Name: directus_policies; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_policies (
    id uuid NOT NULL,
    name character varying(100) NOT NULL,
    icon character varying(64) DEFAULT 'badge'::character varying NOT NULL,
    description text,
    ip_access text,
    enforce_tfa boolean DEFAULT false NOT NULL,
    admin_access boolean DEFAULT false NOT NULL,
    app_access boolean DEFAULT false NOT NULL
);


ALTER TABLE public.directus_policies OWNER TO abroad;

--
-- Name: directus_presets; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_presets (
    id integer NOT NULL,
    bookmark character varying(255),
    "user" uuid,
    role uuid,
    collection character varying(64),
    search character varying(100),
    layout character varying(100) DEFAULT 'tabular'::character varying,
    layout_query json,
    layout_options json,
    refresh_interval integer,
    filter json,
    icon character varying(64) DEFAULT 'bookmark'::character varying,
    color character varying(255)
);


ALTER TABLE public.directus_presets OWNER TO abroad;

--
-- Name: directus_presets_id_seq; Type: SEQUENCE; Schema: public; Owner: abroad
--

CREATE SEQUENCE public.directus_presets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.directus_presets_id_seq OWNER TO abroad;

--
-- Name: directus_presets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: abroad
--

ALTER SEQUENCE public.directus_presets_id_seq OWNED BY public.directus_presets.id;


--
-- Name: directus_relations; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_relations (
    id integer NOT NULL,
    many_collection character varying(64) NOT NULL,
    many_field character varying(64) NOT NULL,
    one_collection character varying(64),
    one_field character varying(64),
    one_collection_field character varying(64),
    one_allowed_collections text,
    junction_field character varying(64),
    sort_field character varying(64),
    one_deselect_action character varying(255) DEFAULT 'nullify'::character varying NOT NULL
);


ALTER TABLE public.directus_relations OWNER TO abroad;

--
-- Name: directus_relations_id_seq; Type: SEQUENCE; Schema: public; Owner: abroad
--

CREATE SEQUENCE public.directus_relations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.directus_relations_id_seq OWNER TO abroad;

--
-- Name: directus_relations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: abroad
--

ALTER SEQUENCE public.directus_relations_id_seq OWNED BY public.directus_relations.id;


--
-- Name: directus_revisions; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_revisions (
    id integer NOT NULL,
    activity integer NOT NULL,
    collection character varying(64) NOT NULL,
    item character varying(255) NOT NULL,
    data json,
    delta json,
    parent integer,
    version uuid
);


ALTER TABLE public.directus_revisions OWNER TO abroad;

--
-- Name: directus_revisions_id_seq; Type: SEQUENCE; Schema: public; Owner: abroad
--

CREATE SEQUENCE public.directus_revisions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.directus_revisions_id_seq OWNER TO abroad;

--
-- Name: directus_revisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: abroad
--

ALTER SEQUENCE public.directus_revisions_id_seq OWNED BY public.directus_revisions.id;


--
-- Name: directus_roles; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_roles (
    id uuid NOT NULL,
    name character varying(100) NOT NULL,
    icon character varying(64) DEFAULT 'supervised_user_circle'::character varying NOT NULL,
    description text,
    parent uuid
);


ALTER TABLE public.directus_roles OWNER TO abroad;

--
-- Name: directus_sessions; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_sessions (
    token character varying(64) NOT NULL,
    "user" uuid,
    expires timestamp with time zone NOT NULL,
    ip character varying(255),
    user_agent text,
    share uuid,
    origin character varying(255),
    next_token character varying(64)
);


ALTER TABLE public.directus_sessions OWNER TO abroad;

--
-- Name: directus_settings; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_settings (
    id integer NOT NULL,
    project_name character varying(100) DEFAULT 'Directus'::character varying NOT NULL,
    project_url character varying(255),
    project_color character varying(255) DEFAULT '#6644FF'::character varying NOT NULL,
    project_logo uuid,
    public_foreground uuid,
    public_background uuid,
    public_note text,
    auth_login_attempts integer DEFAULT 25,
    auth_password_policy character varying(100),
    storage_asset_transform character varying(7) DEFAULT 'all'::character varying,
    storage_asset_presets json,
    custom_css text,
    storage_default_folder uuid,
    basemaps json,
    mapbox_key character varying(255),
    module_bar json,
    project_descriptor character varying(100),
    default_language character varying(255) DEFAULT 'en-US'::character varying NOT NULL,
    custom_aspect_ratios json,
    public_favicon uuid,
    default_appearance character varying(255) DEFAULT 'auto'::character varying NOT NULL,
    default_theme_light character varying(255),
    theme_light_overrides json,
    default_theme_dark character varying(255),
    theme_dark_overrides json,
    report_error_url character varying(255),
    report_bug_url character varying(255),
    report_feature_url character varying(255),
    public_registration boolean DEFAULT false NOT NULL,
    public_registration_verify_email boolean DEFAULT true NOT NULL,
    public_registration_role uuid,
    public_registration_email_filter json,
    visual_editor_urls json,
    project_id uuid,
    mcp_enabled boolean DEFAULT false NOT NULL,
    mcp_allow_deletes boolean DEFAULT false NOT NULL,
    mcp_prompts_collection character varying(255) DEFAULT NULL::character varying,
    mcp_system_prompt_enabled boolean DEFAULT true NOT NULL,
    mcp_system_prompt text,
    project_owner character varying(255),
    project_usage character varying(255),
    org_name character varying(255),
    product_updates boolean,
    project_status character varying(255),
    ai_openai_api_key text,
    ai_anthropic_api_key text,
    ai_system_prompt text,
    ai_google_api_key text,
    ai_openai_compatible_api_key text,
    ai_openai_compatible_base_url text,
    ai_openai_compatible_name text,
    ai_openai_compatible_models json,
    ai_openai_compatible_headers json,
    ai_openai_allowed_models json,
    ai_anthropic_allowed_models json,
    ai_google_allowed_models json,
    collaborative_editing_enabled boolean DEFAULT false NOT NULL
);


ALTER TABLE public.directus_settings OWNER TO abroad;

--
-- Name: directus_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: abroad
--

CREATE SEQUENCE public.directus_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.directus_settings_id_seq OWNER TO abroad;

--
-- Name: directus_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: abroad
--

ALTER SEQUENCE public.directus_settings_id_seq OWNED BY public.directus_settings.id;


--
-- Name: directus_shares; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_shares (
    id uuid NOT NULL,
    name character varying(255),
    collection character varying(64) NOT NULL,
    item character varying(255) NOT NULL,
    role uuid,
    password character varying(255),
    user_created uuid,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    date_start timestamp with time zone,
    date_end timestamp with time zone,
    times_used integer DEFAULT 0,
    max_uses integer
);


ALTER TABLE public.directus_shares OWNER TO abroad;

--
-- Name: directus_translations; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_translations (
    id uuid NOT NULL,
    language character varying(255) NOT NULL,
    key character varying(255) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.directus_translations OWNER TO abroad;

--
-- Name: directus_users; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_users (
    id uuid NOT NULL,
    first_name character varying(50),
    last_name character varying(50),
    email character varying(128),
    password character varying(255),
    location character varying(255),
    title character varying(50),
    description text,
    tags json,
    avatar uuid,
    language character varying(255) DEFAULT NULL::character varying,
    tfa_secret character varying(255),
    status character varying(16) DEFAULT 'active'::character varying NOT NULL,
    role uuid,
    token character varying(255),
    last_access timestamp with time zone,
    last_page character varying(255),
    provider character varying(128) DEFAULT 'default'::character varying NOT NULL,
    external_identifier character varying(255),
    auth_data json,
    email_notifications boolean DEFAULT true,
    appearance character varying(255),
    theme_dark character varying(255),
    theme_light character varying(255),
    theme_light_overrides json,
    theme_dark_overrides json,
    text_direction character varying(255) DEFAULT 'auto'::character varying NOT NULL
);


ALTER TABLE public.directus_users OWNER TO abroad;

--
-- Name: directus_versions; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.directus_versions (
    id uuid NOT NULL,
    key character varying(64) NOT NULL,
    name character varying(255),
    collection character varying(64) NOT NULL,
    item character varying(255) NOT NULL,
    hash character varying(255),
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    date_updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid,
    user_updated uuid,
    delta json
);


ALTER TABLE public.directus_versions OWNER TO abroad;

--
-- Name: enquiries; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.enquiries (
    id uuid NOT NULL,
    full_name character varying(180) NOT NULL,
    email character varying(255),
    phone character varying(30),
    preferred_country_id uuid,
    planned_intake character varying(100),
    source_page character varying(150),
    status character varying(30) DEFAULT 'new'::character varying NOT NULL,
    assigned_to uuid,
    internal_notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    CONSTRAINT ck_enquiries_status CHECK (((status)::text = ANY ((ARRAY['new'::character varying, 'contacted'::character varying, 'in_progress'::character varying, 'closed'::character varying])::text[])))
);


ALTER TABLE public.enquiries OWNER TO abroad;

--
-- Name: page_content; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.page_content (
    id uuid NOT NULL,
    page_key character varying(100) NOT NULL,
    section_key character varying(100) NOT NULL,
    content_key character varying(100) NOT NULL,
    content_value jsonb,
    status character varying(30) DEFAULT 'draft'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    CONSTRAINT ck_page_content_status CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'pending_review'::character varying, 'published'::character varying, 'archived'::character varying])::text[])))
);


ALTER TABLE public.page_content OWNER TO abroad;

--
-- Name: popular_searches; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.popular_searches (
    id uuid NOT NULL,
    label character varying(180) NOT NULL,
    target_type character varying(30) NOT NULL,
    subject_id uuid,
    specialization_id uuid,
    display_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    CONSTRAINT ck_popular_searches_target_reference CHECK (((((target_type)::text = 'subject'::text) AND (subject_id IS NOT NULL) AND (specialization_id IS NULL)) OR (((target_type)::text = 'specialization'::text) AND (specialization_id IS NOT NULL) AND (subject_id IS NULL)))),
    CONSTRAINT ck_popular_searches_target_type CHECK (((target_type)::text = ANY ((ARRAY['subject'::character varying, 'specialization'::character varying])::text[])))
);


ALTER TABLE public.popular_searches OWNER TO abroad;

--
-- Name: specializations; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.specializations (
    id uuid NOT NULL,
    subject_id uuid NOT NULL,
    name character varying(180) NOT NULL,
    slug character varying(200) NOT NULL,
    description text,
    is_featured boolean DEFAULT false NOT NULL,
    status character varying(30) DEFAULT 'draft'::character varying NOT NULL,
    display_order integer DEFAULT 0 NOT NULL,
    created_by uuid,
    updated_by uuid,
    reviewed_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    published_at timestamp with time zone,
    CONSTRAINT ck_specializations_status CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'pending_review'::character varying, 'published'::character varying, 'archived'::character varying])::text[])))
);


ALTER TABLE public.specializations OWNER TO abroad;

--
-- Name: study_levels; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.study_levels (
    id uuid NOT NULL,
    name character varying(150) NOT NULL,
    slug character varying(180) NOT NULL,
    description text,
    duration character varying(100),
    status character varying(30) DEFAULT 'draft'::character varying NOT NULL,
    display_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    entry_label character varying,
    requirements jsonb,
    CONSTRAINT ck_study_levels_status CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'pending_review'::character varying, 'published'::character varying, 'archived'::character varying])::text[])))
);


ALTER TABLE public.study_levels OWNER TO abroad;

--
-- Name: subject_sections; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.subject_sections (
    id uuid NOT NULL,
    subject_id uuid NOT NULL,
    section character varying(30) NOT NULL,
    title character varying(200) NOT NULL,
    subtitle character varying(200),
    body text,
    url character varying(500),
    is_sponsored boolean DEFAULT false NOT NULL,
    status character varying(30) DEFAULT 'draft'::character varying NOT NULL,
    display_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    study_level_id uuid,
    specialization_id uuid,
    CONSTRAINT ck_subject_sections_section CHECK (((section)::text = ANY ((ARRAY['about'::character varying, 'why'::character varying, 'industry'::character varying, 'company'::character varying, 'advertisement'::character varying, 'cta'::character varying, 'course'::character varying, 'destination'::character varying, 'university'::character varying])::text[]))),
    CONSTRAINT ck_subject_sections_status CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'pending_review'::character varying, 'published'::character varying, 'archived'::character varying])::text[])))
);


ALTER TABLE public.subject_sections OWNER TO abroad;

--
-- Name: subject_study_levels; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.subject_study_levels (
    id uuid NOT NULL,
    subject_id uuid NOT NULL,
    study_level_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.subject_study_levels OWNER TO abroad;

--
-- Name: subjects; Type: TABLE; Schema: public; Owner: abroad
--

CREATE TABLE public.subjects (
    id uuid NOT NULL,
    name character varying(150) NOT NULL,
    slug character varying(180) NOT NULL,
    description text,
    icon_key character varying(100),
    status character varying(30) DEFAULT 'draft'::character varying NOT NULL,
    display_order integer DEFAULT 0 NOT NULL,
    created_by uuid,
    updated_by uuid,
    reviewed_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    published_at timestamp with time zone,
    CONSTRAINT ck_subjects_status CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'pending_review'::character varying, 'published'::character varying, 'archived'::character varying])::text[])))
);


ALTER TABLE public.subjects OWNER TO abroad;

--
-- Name: directus_activity id; Type: DEFAULT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_activity ALTER COLUMN id SET DEFAULT nextval('public.directus_activity_id_seq'::regclass);


--
-- Name: directus_fields id; Type: DEFAULT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_fields ALTER COLUMN id SET DEFAULT nextval('public.directus_fields_id_seq'::regclass);


--
-- Name: directus_notifications id; Type: DEFAULT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_notifications ALTER COLUMN id SET DEFAULT nextval('public.directus_notifications_id_seq'::regclass);


--
-- Name: directus_permissions id; Type: DEFAULT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_permissions ALTER COLUMN id SET DEFAULT nextval('public.directus_permissions_id_seq'::regclass);


--
-- Name: directus_presets id; Type: DEFAULT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_presets ALTER COLUMN id SET DEFAULT nextval('public.directus_presets_id_seq'::regclass);


--
-- Name: directus_relations id; Type: DEFAULT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_relations ALTER COLUMN id SET DEFAULT nextval('public.directus_relations_id_seq'::regclass);


--
-- Name: directus_revisions id; Type: DEFAULT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_revisions ALTER COLUMN id SET DEFAULT nextval('public.directus_revisions_id_seq'::regclass);


--
-- Name: directus_settings id; Type: DEFAULT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_settings ALTER COLUMN id SET DEFAULT nextval('public.directus_settings_id_seq'::regclass);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.alembic_version (version_num) FROM stdin;
8e2f4b6c1a93
\.


--
-- Data for Name: countries; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.countries (id, name, slug, country_code, description, status, display_order, created_at, updated_at) FROM stdin;
2185cbc6-96a6-45bc-8a71-2075c481f00e	America	amr	am	\N	draft	0	2026-11-04 06:48:19.949911+00	\N
27df52ab-b269-4d6a-9151-c80e746565d7	United States of America 	usa	US	xyzzzz	draft	0	2026-11-04 08:19:01.487+00	\N
\.


--
-- Data for Name: directus_access; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_access (id, role, "user", policy, sort) FROM stdin;
ab97840d-ef3a-405d-aa4d-a2c383bd0be4	\N	\N	abf8a154-5b1c-4a46-ac9c-7300570f4f17	1
1e0bd95d-d45d-4c37-9604-4797d5d28929	5fe778c9-7d2e-4178-b3d8-7a656c2abf9a	\N	9e3f5bd1-57f9-4cd1-9c44-c551a6bc707a	\N
\.


--
-- Data for Name: directus_activity; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_activity (id, action, "user", "timestamp", ip, user_agent, collection, item, origin) FROM stdin;
1	login	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 11:02:44.15+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_users	6a46be53-0fda-4049-ac99-592e43454225	http://localhost:8055
2	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 11:03:49.412+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_settings	1	http://localhost:8055
3	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:04:26.077+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	alembic_version	http://localhost:8055
4	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:06:20.145+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	1	http://localhost:8055
5	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:27:10.57+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	countries	http://localhost:8055
6	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:27:45.098+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	2	http://localhost:8055
7	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:28:04.963+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	3	http://localhost:8055
8	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:28:14.556+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	4	http://localhost:8055
9	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:28:20.603+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	5	http://localhost:8055
10	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:28:25.256+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	6	http://localhost:8055
11	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:28:31.955+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	7	http://localhost:8055
12	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:28:36.487+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	8	http://localhost:8055
13	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:28:40.865+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	9	http://localhost:8055
14	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:29:07.372+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	9	http://localhost:8055
15	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:29:10.284+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	10	http://localhost:8055
16	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:29:19.61+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	10	http://localhost:8055
17	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:36:20.621+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	countries	http://localhost:8055
18	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:36:35.268+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	enquiries	http://localhost:8055
19	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:36:48.165+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	enquiries	http://localhost:8055
20	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:36:55.691+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	11	http://localhost:8055
21	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:37:13.854+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	12	http://localhost:8055
22	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:37:22.261+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	13	http://localhost:8055
23	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:37:29.257+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	14	http://localhost:8055
24	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:37:36.061+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	15	http://localhost:8055
25	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:37:58.43+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	16	http://localhost:8055
26	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:38:22.742+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	enquiries	http://localhost:8055
27	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:38:28.62+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	page_content	http://localhost:8055
28	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:38:44.961+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	page_content	http://localhost:8055
29	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:38:47.138+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	popular_searches	http://localhost:8055
30	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:38:57.801+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	popular_searches	http://localhost:8055
31	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:39:06.752+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	specializations	http://localhost:8055
32	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:39:09.985+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	specializations	http://localhost:8055
33	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:39:13.083+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	study_levels	http://localhost:8055
34	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:39:15.981+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	study_levels	http://localhost:8055
35	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:39:18.783+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	subject_study_levels	http://localhost:8055
36	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:39:21.787+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	subject_study_levels	http://localhost:8055
37	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:39:25.958+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	subjects	http://localhost:8055
38	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:39:29.285+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	subjects	http://localhost:8055
39	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:39:53.562+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	subjects	http://localhost:8055
40	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:40:04.175+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	subject_study_levels	http://localhost:8055
41	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:40:24.886+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_collections	specializations	http://localhost:8055
42	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:47:49.426+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	17	http://localhost:8055
43	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:52:09.467+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	18	http://localhost:8055
44	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:53:28.834+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	18	http://localhost:8055
45	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:53:32.862+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	19	http://localhost:8055
46	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 16:53:47.782+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	19	http://localhost:8055
47	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-02 18:17:49.796+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	20	http://localhost:8055
48	login	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 06:51:16.23+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_users	6a46be53-0fda-4049-ac99-592e43454225	http://localhost:8055
49	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 06:54:17.619+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	2	http://localhost:8055
50	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 06:54:44.538+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	3	http://localhost:8055
51	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 06:55:15.361+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	4	http://localhost:8055
52	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 06:56:47.447+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	5	http://localhost:8055
53	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 06:57:34.657+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	6	http://localhost:8055
54	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 07:02:13.249+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	7	http://localhost:8055
55	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 07:04:41.267+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	7	http://localhost:8055
56	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 07:07:28.782+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	8	http://localhost:8055
57	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 07:08:45.028+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	9	http://localhost:8055
58	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 07:09:42.987+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	10	http://localhost:8055
59	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:19:01.497+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	countries	27df52ab-b269-4d6a-9151-c80e746565d7	http://localhost:8055
60	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:28:39.145+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	18	http://localhost:8055
61	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:28:59.546+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	19	http://localhost:8055
62	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:29:21.852+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	20	http://localhost:8055
63	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:29:25.829+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	21	http://localhost:8055
64	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:29:51.565+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	21	http://localhost:8055
65	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:29:55.163+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	22	http://localhost:8055
66	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:30:10.408+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	22	http://localhost:8055
67	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:30:12.474+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	23	http://localhost:8055
68	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:32:43.967+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	23	http://localhost:8055
69	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:33:02.395+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	24	http://localhost:8055
70	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:33:29.153+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	24	http://localhost:8055
71	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:33:48.586+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	25	http://localhost:8055
72	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:35:12.194+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	17	http://localhost:8055
73	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:35:19.695+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	26	http://localhost:8055
74	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:35:28.295+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	26	http://localhost:8055
75	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:37:38.515+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	27	http://localhost:8055
76	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:37:50.577+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	27	http://localhost:8055
77	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:39:12.502+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	28	http://localhost:8055
78	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:40:07.9+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	28	http://localhost:8055
79	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:40:10.711+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	29	http://localhost:8055
80	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:41:03.271+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	29	http://localhost:8055
81	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:50:10.356+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	subjects	d16938d0-d47b-4c82-9208-6c8b4f853c4d	http://localhost:8055
82	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:54:00.02+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	subjects	2961fdfb-3e0a-4556-bf63-b609b5f5da89	http://localhost:8055
83	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 08:57:19.158+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	subjects	2961fdfb-3e0a-4556-bf63-b609b5f5da89	http://localhost:8055
84	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-04 16:14:36.735+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	subjects	3f4fc1dd-f807-46a2-a08b-76c8ea097a34	http://localhost:8055
85	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:45:44.052+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	30	http://localhost:8055
86	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:46:11.406+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	30	http://localhost:8055
87	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:46:14.42+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	31	http://localhost:8055
88	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:47:21.136+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	31	http://localhost:8055
89	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:47:23.957+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	32	http://localhost:8055
90	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:47:38.862+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	32	http://localhost:8055
91	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:47:41.687+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	33	http://localhost:8055
92	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:49:06.763+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	33	http://localhost:8055
93	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:49:09.24+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	34	http://localhost:8055
94	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:49:20.92+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	34	http://localhost:8055
95	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:49:23.781+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	35	http://localhost:8055
96	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:50:16.241+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	35	http://localhost:8055
97	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:50:19.315+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	36	http://localhost:8055
98	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:52:48.746+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	36	http://localhost:8055
99	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:52:54.072+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	37	http://localhost:8055
100	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:53:30.237+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	37	http://localhost:8055
101	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:53:33.217+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	38	http://localhost:8055
102	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:54:07.742+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	38	http://localhost:8055
103	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:54:12.469+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	39	http://localhost:8055
104	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:54:50.501+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	39	http://localhost:8055
105	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:54:53.83+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	40	http://localhost:8055
106	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:55:15.903+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	40	http://localhost:8055
107	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:55:19.713+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	41	http://localhost:8055
108	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:55:48.201+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	41	http://localhost:8055
109	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:55:50.855+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	42	http://localhost:8055
110	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:56:04.841+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	42	http://localhost:8055
111	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:56:15.091+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	43	http://localhost:8055
112	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 04:56:42.38+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	43	http://localhost:8055
113	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:32:39.779+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	44	http://localhost:8055
114	delete	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:33:33.009+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	44	http://localhost:8055
115	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:34:24.491+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	45	http://localhost:8055
116	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:35:23.6+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	46	http://localhost:8055
117	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:35:43.414+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	46	http://localhost:8055
118	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:35:46.284+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	47	http://localhost:8055
119	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:36:06.957+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	47	http://localhost:8055
120	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:36:09.63+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	48	http://localhost:8055
121	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:36:19.259+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	48	http://localhost:8055
122	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:36:21.905+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	49	http://localhost:8055
123	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:36:33.013+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	49	http://localhost:8055
124	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:36:48.742+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	50	http://localhost:8055
125	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:39:29.356+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	50	http://localhost:8055
126	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:40:52.511+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	51	http://localhost:8055
127	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:42:29.713+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	51	http://localhost:8055
128	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:42:58.581+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	51	http://localhost:8055
129	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:43:02.146+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	52	http://localhost:8055
130	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:43:14.614+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	52	http://localhost:8055
131	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:43:17.217+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	53	http://localhost:8055
132	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 05:43:24.23+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	53	http://localhost:8055
133	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 12:31:08.467+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	page_content	613e695c-2898-4aaa-ab84-76678721520b	http://localhost:8055
134	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 12:32:04.176+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	page_content	613e695c-2898-4aaa-ab84-76678721520b	http://localhost:8055
135	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 12:44:37.753+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	page_content	613e695c-2898-4aaa-ab84-76678721520b	http://localhost:8055
136	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 13:51:23.79+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	subjects	551051d3-3f41-429f-8b66-71611c7d5eb2	http://localhost:8055
137	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 13:52:08.03+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	subjects	551051d3-3f41-429f-8b66-71611c7d5eb2	http://localhost:8055
138	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 13:59:44.285+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	subjects	36d814c6-1ed9-4324-8c4d-48b9ab12b09b	http://localhost:8055
139	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 14:01:09.625+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	subjects	36d814c6-1ed9-4324-8c4d-48b9ab12b09b	http://localhost:8055
140	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 14:02:02.913+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	subjects	36d814c6-1ed9-4324-8c4d-48b9ab12b09b	http://localhost:8055
141	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-05 14:04:54.697+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	specializations	be5dc49f-e225-43da-bce1-d4fc633bfd54	http://localhost:8055
142	login	6a46be53-0fda-4049-ac99-592e43454225	2026-11-06 17:00:45.731+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_users	6a46be53-0fda-4049-ac99-592e43454225	http://localhost:8055
143	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-06 17:14:28.839+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	subjects	9ddff52b-489d-4623-9e52-472183f23e75	http://localhost:8055
144	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-06 17:15:11.789+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	subjects	9ddff52b-489d-4623-9e52-472183f23e75	http://localhost:8055
145	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-06 17:16:39.592+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	specializations	c6973d9f-a1ce-4500-85dd-97ec3ccf00ba	http://localhost:8055
146	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 06:33:56.552+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	54	http://localhost:8055
147	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 06:34:01.719+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	55	http://localhost:8055
148	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 06:34:24.078+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	55	http://localhost:8055
149	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 06:34:26.198+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	56	http://localhost:8055
150	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 06:34:34.869+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	56	http://localhost:8055
151	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 06:35:10.291+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	57	http://localhost:8055
152	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 06:35:49.024+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	58	http://localhost:8055
153	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 06:36:17.971+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	58	http://localhost:8055
154	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 06:36:33.258+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	54	http://localhost:8055
155	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 06:36:42.438+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	59	http://localhost:8055
156	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 06:39:10.32+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	59	http://localhost:8055
157	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 06:39:18.489+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	60	http://localhost:8055
158	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 06:39:25.82+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	60	http://localhost:8055
159	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 06:39:28.695+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	61	http://localhost:8055
160	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 06:39:40.279+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	61	http://localhost:8055
161	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 06:39:42.825+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	62	http://localhost:8055
162	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 06:39:50.448+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	62	http://localhost:8055
163	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 08:05:30.851+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	page_content	613e695c-2898-4aaa-ab84-76678721520b	http://localhost:8055
164	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 08:08:41.672+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	subjects	449ded41-2db3-4675-b49d-7e0feb87206f	http://localhost:8055
165	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 16:36:39.265+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	study_levels	38daafc4-ca6b-4511-9bbf-6fa2644130c8	http://localhost:8055
166	login	6a46be53-0fda-4049-ac99-592e43454225	2026-11-09 03:03:17.912+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_users	6a46be53-0fda-4049-ac99-592e43454225	http://localhost:8055
167	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-09 03:13:04.954+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	study_levels	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	http://localhost:8055
168	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-09 03:42:30.317+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	63	http://localhost:8055
169	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-09 03:46:51.51+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	63	http://localhost:8055
170	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-09 03:46:54.156+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	64	http://localhost:8055
171	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-09 03:47:52.563+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	64	http://localhost:8055
172	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-09 04:07:03.243+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	study_levels	6a18853c-07ce-47c2-a0a5-a5c4d1a3d2da	http://localhost:8055
173	delete	6a46be53-0fda-4049-ac99-592e43454225	2026-11-09 10:12:28.674+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	study_levels	38daafc4-ca6b-4511-9bbf-6fa2644130c8	http://localhost:8055
174	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-09 10:15:07.4+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	study_levels	6a18853c-07ce-47c2-a0a5-a5c4d1a3d2da	http://localhost:8055
175	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-09 10:17:40.722+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	study_levels	6a18853c-07ce-47c2-a0a5-a5c4d1a3d2da	http://localhost:8055
176	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-09 20:26:26.118+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	subject_sections	4ee5582d-591c-4001-b632-ea1d9a0fc654	http://localhost:8055
177	create	6a46be53-0fda-4049-ac99-592e43454225	2026-11-09 20:46:15.755+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	subject_sections	44deb987-60a3-4d31-a5ee-60e6b8cb06ff	http://localhost:8055
178	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-10 04:32:56.832+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	subject_sections	ab2f0545-8945-48e0-a1f0-4a798339ff64	http://localhost:8055
179	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-10 04:35:09.418+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	subject_sections	f104f072-fe15-4570-87aa-e2966b96686c	http://localhost:8055
180	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-10 04:44:45.346+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	22	http://localhost:8055
181	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-10 04:45:59.932+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	58	http://localhost:8055
182	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-10 04:47:24.206+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	34	http://localhost:8055
183	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-10 04:48:58.882+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	22	http://localhost:8055
184	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-10 04:50:54.853+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	directus_fields	34	http://localhost:8055
185	update	6a46be53-0fda-4049-ac99-592e43454225	2026-11-10 08:58:46.748+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	subject_sections	cd233e55-6cc8-44be-8202-b0b0f23fc5b2	http://localhost:8055
\.


--
-- Data for Name: directus_collections; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_collections (collection, icon, note, display_template, hidden, singleton, translations, archive_field, archive_app_filter, archive_value, unarchive_value, sort_field, accountability, color, item_duplication_fields, sort, "group", collapse, preview_url, versioning) FROM stdin;
alembic_version	\N	\N	\N	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
countries	\N	This will Store Information About Countries 	\N	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
enquiries	\N	Stores Enquiries 	\N	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
page_content	\N	it will store contents of the page	\N	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
popular_searches	\N	search bar conetnt	\N	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
study_levels	\N	\N	\N	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
subjects	\N	stores all teh subjects 	\N	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
subject_study_levels	\N	study levels of the site 	\N	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
specializations	\N	specilaization of students 	\N	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
subject_sections	view_agenda	Extra content blocks shown on the Subject page (why study, industries, companies, courses, destinations, universities).	{{section}} - {{title}}	f	f	\N	\N	t	\N	\N	display_order	all	\N	\N	\N	\N	open	\N	f
\.


--
-- Data for Name: directus_comments; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_comments (id, collection, item, comment, date_created, date_updated, user_created, user_updated) FROM stdin;
\.


--
-- Data for Name: directus_dashboards; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_dashboards (id, name, icon, note, date_created, user_created, color) FROM stdin;
\.


--
-- Data for Name: directus_deployment_projects; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_deployment_projects (id, deployment, external_id, name, date_created, user_created, url, framework, deployable) FROM stdin;
\.


--
-- Data for Name: directus_deployment_runs; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_deployment_runs (id, project, external_id, target, date_created, user_created, status, url, started_at, completed_at) FROM stdin;
\.


--
-- Data for Name: directus_deployments; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_deployments (id, provider, credentials, options, date_created, user_created, webhook_ids, webhook_secret, last_synced_at) FROM stdin;
\.


--
-- Data for Name: directus_extensions; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_extensions (enabled, id, folder, source, bundle) FROM stdin;
\.


--
-- Data for Name: directus_fields; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_fields (id, collection, field, special, interface, options, display, display_options, readonly, hidden, sort, width, translations, note, conditions, required, "group", validation, validation_message, searchable) FROM stdin;
1	alembic_version	version_num	\N	\N	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
11	enquiries	id	uuid	\N	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
12	enquiries	full_name	\N	\N	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
13	enquiries	email	\N	\N	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
14	enquiries	phone	\N	\N	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
15	enquiries	preferred_country_id	uuid	\N	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
16	enquiries	planned_intake	\N	\N	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
40	specializations	reviewed_by	uuid	select-dropdown-m2o	{"template":"{{first_name}} {{last_name}}"}	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
3	countries	name	\N	input	\N	\N	\N	f	f	\N	full	\N	\N	\N	t	\N	\N	\N	f
5	countries	country_code	\N	input	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	f
6	countries	description	\N	input-multiline	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
7	countries	status	\N	select-dropdown	{"choices":[{"text":"draft","value":"draft"},{"text":"pending_review","value":"pending_review"},{"text":"published","value":"published"},{"text":"archieved","value":"archieved"}]}	\N	\N	f	f	\N	full	\N	\N	\N	t	\N	\N	\N	t
8	countries	display_order	\N	\N	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	f
2	countries	id	uuid	\N	\N	\N	\N	t	t	\N	full	\N	\N	\N	f	\N	\N	\N	f
9	countries	created_at	date-created	datetime	\N	\N	\N	t	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
10	countries	updated_at	date-updated	datetime	\N	\N	\N	t	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
57	study_levels	slug	\N	\N	{"slug": true, "trim": true, "placeholder": "Created automatically from the name"}	\N	\N	f	f	\N	full	\N	Leave empty - it is created automatically from the name	\N	f	\N	\N	\N	t
19	subjects	name	\N	input	\N	\N	\N	f	f	\N	full	\N	\N	\N	t	\N	\N	\N	t
20	subjects	icon_key	\N	input	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
56	study_levels	name	\N	\N	\N	\N	\N	f	f	\N	full	\N	\N	\N	t	\N	\N	\N	t
23	subjects	status	\N	select-dropdown	{"choices":[{"text":"draft","value":"draft"},{"text":"pending_review","value":"pending_review"},{"text":"published","value":"published"},{"text":"archieved","value":"archieved"}]}	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
24	subjects	display_order	\N	input	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
43	specializations	published_at	\N	datetime	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
27	subjects	published_at	\N	datetime	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
30	specializations	id	uuid	input	\N	\N	\N	t	t	\N	full	\N	\N	\N	f	\N	\N	\N	t
29	subjects	reviewed_by	uuid	select-dropdown-m2o	{"template":"{{first_name}} {{last_name}}"}	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
18	subjects	id	uuid	input	\N	\N	\N	t	t	\N	full	\N	\N	\N	f	\N	\N	\N	t
17	subjects	created_at	date-created	datetime	\N	\N	\N	t	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
26	subjects	updated_at	date-updated	datetime	\N	\N	\N	t	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
25	subjects	created_by	user-created,m2o	\N	\N	\N	\N	t	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
28	subjects	updated_by	user-updated,m2o	select-dropdown-m2o	{"template":"{{first_name}} {{last_name}}"}	\N	\N	t	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
46	page_content	id	uuid	input	\N	\N	\N	t	t	\N	full	\N	\N	\N	f	\N	\N	\N	t
31	specializations	subject_id	uuid	select-dropdown-m2o	{"template":"{{name}}"}	\N	\N	f	f	\N	full	\N	\N	\N	t	\N	\N	\N	t
32	specializations	name	\N	input	\N	\N	\N	f	f	\N	full	\N	\N	\N	t	\N	\N	\N	t
35	specializations	is_featured	cast-boolean	boolean	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
36	specializations	status	\N	select-dropdown	{"choices":[{"text":"draft","value":"draft"},{"text":"pending_review","value":"pending_review"},{"text":"published","value":"published"},{"text":"archieved","value":"archieved"}]}	\N	\N	f	f	\N	full	\N	\N	\N	t	\N	\N	\N	t
37	specializations	display_order	\N	input	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
41	specializations	created_at	date-created	datetime	\N	\N	\N	t	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
42	specializations	updated_at	date-updated	datetime	\N	\N	\N	t	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
38	specializations	created_by	user-created,m2o	select-dropdown-m2o	{"template":"{{first_name}} {{last_name}}"}	\N	\N	t	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
39	specializations	updated_by	user-updated,m2o	select-dropdown-m2o	{"template":"{{first_name}} {{last_name}}"}	\N	\N	t	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
47	page_content	page_key	\N	input	\N	\N	\N	f	f	\N	full	\N	\N	\N	t	\N	\N	\N	t
48	page_content	section_key	\N	input	\N	\N	\N	f	f	\N	full	\N	\N	\N	t	\N	\N	\N	t
49	page_content	content_key	\N	input	\N	\N	\N	f	f	\N	full	\N	\N	\N	t	\N	\N	\N	t
50	page_content	content_value	cast-json	input-code	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
54	study_levels	duration	\N	input	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
51	page_content	status	\N	select-dropdown	{"choices":[{"text":"draft","value":"draft"},{"text":"published","value":"published"},{"text":"pending_review","value":"pending_review"},{"text":"archived","value":"archived"}]}	\N	\N	f	f	\N	full	\N	\N	\N	t	\N	\N	\N	t
52	page_content	created_at	date-created	datetime	\N	\N	\N	t	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
53	page_content	updated_at	date-updated	datetime	\N	\N	\N	t	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
63	study_levels	entry_label	\N	input	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
59	study_levels	status	\N	select-dropdown	{"choices":[{"text":"draft","value":"draft"},{"text":"pending_review","value":"pending_review"},{"text":"published","value":"published"},{"text":"archived","value":"archived"}]}	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
60	study_levels	display_order	\N	input	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
4	countries	slug	\N	input	{"slug": true, "trim": true, "placeholder": "Created automatically from the name"}	\N	\N	f	f	\N	full	\N	Leave empty - it is created automatically from the name	\N	f	\N	\N	\N	f
21	subjects	slug	\N	input	{"slug": true, "trim": true, "placeholder": "Created automatically from the name"}	\N	\N	f	f	\N	full	\N	Leave empty - it is created automatically from the name	\N	f	\N	\N	\N	t
55	study_levels	id	uuid	\N	\N	\N	\N	t	t	\N	full	\N	\N	\N	f	\N	\N	\N	t
61	study_levels	created_at	date-created	datetime	\N	\N	\N	t	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
62	study_levels	updated_at	date-updated	datetime	\N	\N	\N	t	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
33	specializations	slug	\N	input	{"slug": true, "trim": true, "placeholder": "Created automatically from the name"}	\N	\N	f	f	\N	full	\N	Leave empty - it is created automatically from the name	\N	f	\N	\N	\N	t
64	study_levels	requirements	cast-json	list	\N	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
58	study_levels	description	\N	input-rich-text-html	{"toolbar":["undo","redo","bold","italic","underline","subscript","superscript","fontfamily","fontsize","h1","h2","h3","h4","h5","h6","alignleft","aligncenter","alignright","alignjustify","alignnone","numlist","bullist","removeformat","cut","copy","paste","remove","selectall","blockquote","customLink","customImage","customMedia","hr","fullscreen","code"]}	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
22	subjects	description	\N	input-rich-text-html	{"toolbar":["undo","redo","bold","italic","underline","subscript","superscript","fontfamily","fontsize","h1","h2","h3","h4","h5","h6","customPre","alignleft","aligncenter","alignright","alignjustify","alignnone","indent","outdent","numlist","bullist","removeformat","cut","copy","paste","remove","selectall","link","blockquote","fullscreen"]}	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
34	specializations	description	\N	input-rich-text-html	{"toolbar":["undo","redo","bold","italic","underline","strikethrough","subscript","superscript","fontfamily","fontsize","h1","h2","h3","h4","h5","h6","alignleft","aligncenter","alignright","alignjustify","alignnone","numlist","bullist","removeformat","cut","copy","paste","remove","link","selectall","hr","fullscreen","ltr rtl"]}	\N	\N	f	f	\N	full	\N	\N	\N	f	\N	\N	\N	t
107	subject_sections	id	uuid	input	\N	\N	\N	t	t	1	full	\N	\N	\N	f	\N	\N	\N	t
108	subject_sections	section	\N	select-dropdown	{"choices":[\n    {"text":"About (level pages)","value":"about"},\n    {"text":"Why study this subject / level","value":"why"},\n    {"text":"Industry","value":"industry"},\n    {"text":"Company","value":"company"},\n    {"text":"Advertisement (level pages)","value":"advertisement"},\n    {"text":"CTA - call to action (level pages)","value":"cta"},\n    {"text":"Course","value":"course"},\n    {"text":"Destination (country)","value":"destination"},\n    {"text":"University","value":"university"}]}	labels	\N	f	f	2	half	\N	Where this item appears. For About, Why study, Advertisement and CTA publish only ONE item per page.	\N	t	\N	\N	\N	t
109	subject_sections	status	\N	select-dropdown	{"choices":[\n    {"text":"Draft","value":"draft"},\n    {"text":"Pending review","value":"pending_review"},\n    {"text":"Published","value":"published"},\n    {"text":"Archived","value":"archived"}]}	labels	\N	f	f	3	half	\N	Only "Published" items appear on the website.	\N	t	\N	\N	\N	t
110	subject_sections	title	\N	input	\N	\N	\N	f	f	4	full	\N	Name of the item, e.g. "Aerospace", "Rolls-Royce", "University of Leeds".	\N	t	\N	\N	\N	t
111	subject_sections	subtitle	\N	input	\N	\N	\N	f	f	5	full	\N	Optional short line, e.g. the city of a university.	\N	f	\N	\N	\N	t
112	subject_sections	body	\N	input-rich-text-html	{"toolbar":["bold","italic","underline","h2","h3","bullist","numlist","link"]}	\N	\N	f	f	6	full	\N	Description text.	\N	f	\N	\N	\N	t
113	subject_sections	url	\N	input	\N	\N	\N	f	f	7	full	\N	Optional link. Must start with https:// (other links are ignored by the website).	\N	f	\N	\N	\N	t
114	subject_sections	is_sponsored	cast-boolean	boolean	{"label":"This item is sponsored"}	\N	\N	f	f	8	half	\N	Shows a "Sponsored" tag on the website.	\N	f	\N	\N	\N	t
115	subject_sections	display_order	\N	input	\N	\N	\N	f	f	9	half	\N	Lower numbers appear first. You can also drag rows to reorder them.	\N	f	\N	\N	\N	t
116	subject_sections	subject_id	m2o	select-dropdown-m2o	{"template":"{{name}}"}	related-values	{"template":"{{name}}"}	f	f	10	full	\N	The subject this item belongs to.	\N	t	\N	\N	\N	t
117	subject_sections	study_level_id	m2o	select-dropdown-m2o	{"template":"{{name}}"}	related-values	{"template":"{{name}}"}	f	f	11	full	\N	Leave EMPTY to show this item on the subject page. Choose a level (e.g. Bachelors) to show it only on that level page of the subject.	\N	f	\N	\N	\N	t
118	subject_sections	specialization_id	m2o	select-dropdown-m2o	{"template":"{{name}}"}	related-values	{"template":"{{name}}"}	f	f	12	full	\N	Leave EMPTY unless this item is for a specialization page (e.g. Civil Engineering). Set it together with Study level to target the specialization + level page (e.g. Civil Engineering + Bachelors). It must belong to the subject chosen above.	\N	f	\N	\N	\N	t
119	subject_sections	created_at	date-created	datetime	\N	datetime	\N	t	t	13	half	\N	\N	\N	f	\N	\N	\N	t
120	subject_sections	updated_at	date-updated	datetime	\N	datetime	\N	t	t	14	half	\N	\N	\N	f	\N	\N	\N	t
121	subjects	sections	o2m	list-o2m	{"template":"{{section}} - {{title}} ({{status}})","enableCreate":true,"enableSelect":false}	related-values	{"template":"{{section}} - {{title}}"}	f	f	\N	full	\N	Extra content for the subject page. Click "Create New", choose the type, fill in the title, set status to Published.	\N	f	\N	\N	\N	t
\.


--
-- Data for Name: directus_files; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_files (id, storage, filename_disk, filename_download, title, type, folder, uploaded_by, created_on, modified_by, modified_on, charset, filesize, width, height, duration, embed, description, location, tags, metadata, focal_point_x, focal_point_y, tus_id, tus_data, uploaded_on) FROM stdin;
\.


--
-- Data for Name: directus_flows; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_flows (id, name, icon, color, description, status, trigger, accountability, options, operation, date_created, user_created) FROM stdin;
\.


--
-- Data for Name: directus_folders; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_folders (id, name, parent) FROM stdin;
\.


--
-- Data for Name: directus_migrations; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_migrations (version, name, "timestamp") FROM stdin;
20201028A	Remove Collection Foreign Keys	2026-11-02 11:01:00.521+00
20201029A	Remove System Relations	2026-11-02 11:01:00.537422+00
20201029B	Remove System Collections	2026-11-02 11:01:00.548193+00
20201029C	Remove System Fields	2026-11-02 11:01:00.563173+00
20201105A	Add Cascade System Relations	2026-11-02 11:01:00.67883+00
20201105B	Change Webhook URL Type	2026-11-02 11:01:00.696154+00
20210225A	Add Relations Sort Field	2026-11-02 11:01:00.708299+00
20210304A	Remove Locked Fields	2026-11-02 11:01:00.716756+00
20210312A	Webhooks Collections Text	2026-11-02 11:01:00.735277+00
20210331A	Add Refresh Interval	2026-11-02 11:01:00.744134+00
20210415A	Make Filesize Nullable	2026-11-02 11:01:00.765353+00
20210416A	Add Collections Accountability	2026-11-02 11:01:00.776528+00
20210422A	Remove Files Interface	2026-11-02 11:01:00.781817+00
20210506A	Rename Interfaces	2026-11-02 11:01:00.822004+00
20210510A	Restructure Relations	2026-11-02 11:01:00.866574+00
20210518A	Add Foreign Key Constraints	2026-11-02 11:01:00.879895+00
20210519A	Add System Fk Triggers	2026-11-02 11:01:00.946053+00
20210521A	Add Collections Icon Color	2026-11-02 11:01:00.954778+00
20210525A	Add Insights	2026-11-02 11:01:01.001321+00
20210608A	Add Deep Clone Config	2026-11-02 11:01:01.009646+00
20210626A	Change Filesize Bigint	2026-11-02 11:01:01.040007+00
20210716A	Add Conditions to Fields	2026-11-02 11:01:01.047609+00
20210721A	Add Default Folder	2026-11-02 11:01:01.061626+00
20210802A	Replace Groups	2026-11-02 11:01:01.070127+00
20210803A	Add Required to Fields	2026-11-02 11:01:01.078429+00
20210805A	Update Groups	2026-11-02 11:01:01.086611+00
20210805B	Change Image Metadata Structure	2026-11-02 11:01:01.094276+00
20210811A	Add Geometry Config	2026-11-02 11:01:01.102234+00
20210831A	Remove Limit Column	2026-11-02 11:01:01.110105+00
20210903A	Add Auth Provider	2026-11-02 11:01:01.151771+00
20210907A	Webhooks Collections Not Null	2026-11-02 11:01:01.169775+00
20210910A	Move Module Setup	2026-11-02 11:01:01.180892+00
20210920A	Webhooks URL Not Null	2026-11-02 11:01:01.199653+00
20210924A	Add Collection Organization	2026-11-02 11:01:01.214424+00
20210927A	Replace Fields Group	2026-11-02 11:01:01.235632+00
20210927B	Replace M2M Interface	2026-11-02 11:01:01.241787+00
20210929A	Rename Login Action	2026-11-02 11:01:01.248956+00
20211007A	Update Presets	2026-11-02 11:01:01.263524+00
20211009A	Add Auth Data	2026-11-02 11:01:01.271383+00
20211016A	Add Webhook Headers	2026-11-02 11:01:01.278838+00
20211103A	Set Unique to User Token	2026-11-02 11:01:01.29211+00
20211103B	Update Special Geometry	2026-11-02 11:01:01.297932+00
20211104A	Remove Collections Listing	2026-11-02 11:01:01.306393+00
20211118A	Add Notifications	2026-11-02 11:01:01.34098+00
20211211A	Add Shares	2026-11-02 11:01:01.386294+00
20211230A	Add Project Descriptor	2026-11-02 11:01:01.394333+00
20220303A	Remove Default Project Color	2026-11-02 11:01:01.412615+00
20220308A	Add Bookmark Icon and Color	2026-11-02 11:01:01.420981+00
20220314A	Add Translation Strings	2026-11-02 11:01:01.428249+00
20220322A	Rename Field Typecast Flags	2026-11-02 11:01:01.435689+00
20220323A	Add Field Validation	2026-11-02 11:01:01.443111+00
20220325A	Fix Typecast Flags	2026-11-02 11:01:01.451436+00
20220325B	Add Default Language	2026-11-02 11:01:01.472821+00
20220402A	Remove Default Value Panel Icon	2026-11-02 11:01:01.490898+00
20220429A	Add Flows	2026-11-02 11:01:01.56644+00
20220429B	Add Color to Insights Icon	2026-11-02 11:01:01.575559+00
20220429C	Drop Non Null From IP of Activity	2026-11-02 11:01:01.591766+00
20220429D	Drop Non Null From Sender of Notifications	2026-11-02 11:01:01.604679+00
20220614A	Rename Hook Trigger to Event	2026-11-02 11:01:01.612419+00
20220801A	Update Notifications Timestamp Column	2026-11-02 11:01:01.632856+00
20220802A	Add Custom Aspect Ratios	2026-11-02 11:01:01.64044+00
20220826A	Add Origin to Accountability	2026-11-02 11:01:01.651254+00
20230401A	Update Material Icons	2026-11-02 11:01:01.669149+00
20230525A	Add Preview Settings	2026-11-02 11:01:01.676048+00
20230526A	Migrate Translation Strings	2026-11-02 11:01:01.69991+00
20230721A	Require Shares Fields	2026-11-02 11:01:01.711878+00
20230823A	Add Content Versioning	2026-11-02 11:01:01.750791+00
20230927A	Themes	2026-11-02 11:01:01.789526+00
20231009A	Update CSV Fields to Text	2026-11-02 11:01:01.800761+00
20231009B	Update Panel Options	2026-11-02 11:01:01.810035+00
20231010A	Add Extensions	2026-11-02 11:01:01.826132+00
20231215A	Add Focalpoints	2026-11-02 11:01:01.835175+00
20240122A	Add Report URL Fields	2026-11-02 11:01:01.849412+00
20240204A	Marketplace	2026-11-02 11:01:01.927922+00
20240305A	Change Useragent Type	2026-11-02 11:01:01.953626+00
20240311A	Deprecate Webhooks	2026-11-02 11:01:01.970826+00
20240422A	Public Registration	2026-11-02 11:01:01.984202+00
20240515A	Add Session Window	2026-11-02 11:01:01.992079+00
20240701A	Add Tus Data	2026-11-02 11:01:01.999593+00
20240716A	Update Files Date Fields	2026-11-02 11:01:02.017485+00
20240806A	Permissions Policies	2026-11-02 11:01:02.14234+00
20240817A	Update Icon Fields Length	2026-11-02 11:01:02.214502+00
20240909A	Separate Comments	2026-11-02 11:01:02.24111+00
20240909B	Consolidate Content Versioning	2026-11-02 11:01:02.249228+00
20240924A	Migrate Legacy Comments	2026-11-02 11:01:02.260714+00
20240924B	Populate Versioning Deltas	2026-11-02 11:01:02.269082+00
20250224A	Visual Editor	2026-11-02 11:01:02.27866+00
20250609A	License Banner	2026-11-02 11:01:02.289959+00
20250613A	Add Project ID	2026-11-02 11:01:02.312269+00
20250718A	Add Direction	2026-11-02 11:01:02.320573+00
20250813A	Add MCP	2026-11-02 11:01:02.332926+00
20251012A	Add Field Searchable	2026-11-02 11:01:02.343556+00
20251014A	Add Project Owner	2026-11-02 11:01:02.5102+00
20251028A	Add Retention Indexes	2026-11-02 11:01:02.649701+00
20251103A	Add AI Settings	2026-11-02 11:01:02.662652+00
20251224A	Remove Webhooks	2026-11-02 11:01:02.674078+00
20260110A	Add AI Provider Settings	2026-11-02 11:01:02.690578+00
20260113A	Add Revisions Index	2026-11-02 11:01:02.735487+00
20260128A	Add Collaborative Editing	2026-11-02 11:01:02.743445+00
20260204A	Add Deployment	2026-11-02 11:01:02.848145+00
20260211A	Add Deployment Webhooks	2026-11-02 11:01:02.863628+00
\.


--
-- Data for Name: directus_notifications; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_notifications (id, "timestamp", status, recipient, sender, subject, message, collection, item) FROM stdin;
\.


--
-- Data for Name: directus_operations; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_operations (id, name, key, type, position_x, position_y, options, resolve, reject, flow, date_created, user_created) FROM stdin;
\.


--
-- Data for Name: directus_panels; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_panels (id, dashboard, name, icon, color, show_header, note, type, position_x, position_y, width, height, options, date_created, user_created) FROM stdin;
\.


--
-- Data for Name: directus_permissions; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_permissions (id, collection, action, permissions, validation, presets, fields, policy) FROM stdin;
\.


--
-- Data for Name: directus_policies; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access) FROM stdin;
abf8a154-5b1c-4a46-ac9c-7300570f4f17	$t:public_label	public	$t:public_description	\N	f	f	f
9e3f5bd1-57f9-4cd1-9c44-c551a6bc707a	Administrator	verified	$t:admin_description	\N	f	t	t
\.


--
-- Data for Name: directus_presets; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_presets (id, bookmark, "user", role, collection, search, layout, layout_query, layout_options, refresh_interval, filter, icon, color) FROM stdin;
1	\N	6a46be53-0fda-4049-ac99-592e43454225	\N	alembic_version	\N	\N	{"tabular":{"page":1}}	\N	\N	\N	bookmark	\N
3	\N	6a46be53-0fda-4049-ac99-592e43454225	\N	specializations	\N	\N	{"tabular":{"page":1}}	\N	\N	\N	bookmark	\N
2	\N	6a46be53-0fda-4049-ac99-592e43454225	\N	subjects	\N	tabular	{"tabular":{"page":1}}	\N	\N	\N	bookmark	\N
4	\N	6a46be53-0fda-4049-ac99-592e43454225	\N	subject_study_levels	\N	\N	{"tabular":{"page":1}}	\N	\N	\N	bookmark	\N
5	\N	6a46be53-0fda-4049-ac99-592e43454225	\N	subject_sections	\N	\N	{"tabular":{"page":1,"fields":["section","status","subtitle","title"]}}	{"tabular":{"widths":{"section":144,"status":144,"subtitle":144,"title":500.25}}}	\N	\N	bookmark	\N
\.


--
-- Data for Name: directus_relations; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_relations (id, many_collection, many_field, one_collection, one_field, one_collection_field, one_allowed_collections, junction_field, sort_field, one_deselect_action) FROM stdin;
1	specializations	subject_id	subjects	\N	\N	\N	\N	\N	nullify
8	subject_sections	subject_id	subjects	sections	\N	\N	\N	display_order	delete
9	subject_sections	study_level_id	study_levels	\N	\N	\N	\N	\N	nullify
10	subject_sections	specialization_id	specializations	\N	\N	\N	\N	\N	nullify
\.


--
-- Data for Name: directus_revisions; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_revisions (id, activity, collection, item, data, delta, parent, version) FROM stdin;
1	2	directus_settings	1	{"id":1,"project_name":"Directus","project_url":null,"project_color":"#6644FF","public_note":null,"auth_login_attempts":25,"auth_password_policy":null,"storage_asset_transform":"all","storage_asset_presets":null,"custom_css":null,"basemaps":null,"mapbox_key":null,"module_bar":null,"project_descriptor":null,"default_language":"en-US","custom_aspect_ratios":null,"default_appearance":"auto","default_theme_light":null,"theme_light_overrides":null,"default_theme_dark":null,"theme_dark_overrides":null,"report_error_url":null,"report_bug_url":null,"report_feature_url":null,"public_registration":false,"public_registration_verify_email":true,"public_registration_email_filter":null,"visual_editor_urls":null,"project_id":"01a19beb-76e4-7174-884f-c6470cff8f61","mcp_enabled":false,"mcp_allow_deletes":false,"mcp_prompts_collection":null,"mcp_system_prompt_enabled":true,"mcp_system_prompt":null,"project_owner":"tech@universta.com","project_usage":"commercial","org_name":"Universta","product_updates":true,"project_status":null,"ai_openai_api_key":null,"ai_anthropic_api_key":null,"ai_system_prompt":null,"ai_google_api_key":null,"ai_openai_compatible_api_key":null,"ai_openai_compatible_base_url":null,"ai_openai_compatible_name":null,"ai_openai_compatible_models":null,"ai_openai_compatible_headers":null,"ai_openai_allowed_models":["gpt-5-nano","gpt-5-mini","gpt-5"],"ai_anthropic_allowed_models":["claude-haiku-4-5","claude-sonnet-4-5"],"ai_google_allowed_models":["gemini-3-pro-preview","gemini-3-flash-preview","gemini-2.5-pro","gemini-2.5-flash"],"collaborative_editing_enabled":false}	{"project_owner":"tech@universta.com","project_usage":"commercial","org_name":"Universta","product_updates":true,"project_status":null}	\N	\N
2	3	directus_collections	alembic_version	{"collection":"alembic_version"}	{"collection":"alembic_version"}	\N	\N
3	4	directus_fields	1	{"special":null,"field":"version_num"}	{"special":null,"field":"version_num"}	\N	\N
4	5	directus_collections	countries	{"collection":"countries"}	{"collection":"countries"}	\N	\N
5	6	directus_fields	2	{"special":["uuid"],"field":"id"}	{"special":["uuid"],"field":"id"}	\N	\N
6	7	directus_fields	3	{"special":null,"field":"name"}	{"special":null,"field":"name"}	\N	\N
7	8	directus_fields	4	{"special":null,"field":"slug"}	{"special":null,"field":"slug"}	\N	\N
8	9	directus_fields	5	{"special":null,"field":"country_code"}	{"special":null,"field":"country_code"}	\N	\N
9	10	directus_fields	6	{"special":null,"field":"description"}	{"special":null,"field":"description"}	\N	\N
10	11	directus_fields	7	{"special":null,"field":"status"}	{"special":null,"field":"status"}	\N	\N
11	12	directus_fields	8	{"special":null,"field":"display_order"}	{"special":null,"field":"display_order"}	\N	\N
12	13	directus_fields	9	{"special":null,"field":"created_at"}	{"special":null,"field":"created_at"}	\N	\N
13	14	directus_fields	9	{"id":9,"field":"created_at","special":["date-created","date-updated"],"interface":null,"options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"countries","field":"created_at","special":["date-created","date-updated"]}	\N	\N
14	15	directus_fields	10	{"special":null,"field":"updated_at"}	{"special":null,"field":"updated_at"}	\N	\N
15	16	directus_fields	10	{"id":10,"field":"updated_at","special":["date-created","date-updated"],"interface":null,"options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"countries","field":"updated_at","special":["date-created","date-updated"]}	\N	\N
16	17	directus_collections	countries	{"collection":"countries","icon":null,"note":"This will Store Information About Countries ","display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":null,"collapse":"open","preview_url":null,"versioning":false}	{"note":"This will Store Information About Countries "}	\N	\N
17	18	directus_collections	enquiries	{"hidden":true,"collection":"enquiries"}	{"hidden":true,"collection":"enquiries"}	\N	\N
18	19	directus_collections	enquiries	{"collection":"enquiries","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":null,"collapse":"open","preview_url":null,"versioning":false}	{"hidden":false}	\N	\N
19	20	directus_fields	11	{"special":["uuid"],"field":"id"}	{"special":["uuid"],"field":"id"}	\N	\N
20	21	directus_fields	12	{"special":null,"field":"full_name"}	{"special":null,"field":"full_name"}	\N	\N
21	22	directus_fields	13	{"special":null,"field":"email"}	{"special":null,"field":"email"}	\N	\N
22	23	directus_fields	14	{"special":null,"field":"phone"}	{"special":null,"field":"phone"}	\N	\N
23	24	directus_fields	15	{"special":["uuid"],"field":"preferred_country_id"}	{"special":["uuid"],"field":"preferred_country_id"}	\N	\N
24	25	directus_fields	16	{"special":null,"field":"planned_intake"}	{"special":null,"field":"planned_intake"}	\N	\N
25	26	directus_collections	enquiries	{"collection":"enquiries","icon":null,"note":"Stores Enquiries ","display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":null,"collapse":"open","preview_url":null,"versioning":false}	{"note":"Stores Enquiries "}	\N	\N
26	27	directus_collections	page_content	{"collection":"page_content"}	{"collection":"page_content"}	\N	\N
27	28	directus_collections	page_content	{"collection":"page_content","icon":null,"note":"it will store contents of the page","display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":null,"collapse":"open","preview_url":null,"versioning":false}	{"note":"it will store contents of the page"}	\N	\N
28	29	directus_collections	popular_searches	{"collection":"popular_searches"}	{"collection":"popular_searches"}	\N	\N
29	30	directus_collections	popular_searches	{"collection":"popular_searches","icon":null,"note":"search bar conetnt","display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":null,"collapse":"open","preview_url":null,"versioning":false}	{"note":"search bar conetnt"}	\N	\N
30	31	directus_collections	specializations	{"hidden":true,"collection":"specializations"}	{"hidden":true,"collection":"specializations"}	\N	\N
31	32	directus_collections	specializations	{"collection":"specializations","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":null,"collapse":"open","preview_url":null,"versioning":false}	{"hidden":false}	\N	\N
32	33	directus_collections	study_levels	{"hidden":true,"collection":"study_levels"}	{"hidden":true,"collection":"study_levels"}	\N	\N
33	34	directus_collections	study_levels	{"collection":"study_levels","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":null,"collapse":"open","preview_url":null,"versioning":false}	{"hidden":false}	\N	\N
34	35	directus_collections	subject_study_levels	{"hidden":true,"collection":"subject_study_levels"}	{"hidden":true,"collection":"subject_study_levels"}	\N	\N
35	36	directus_collections	subject_study_levels	{"collection":"subject_study_levels","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":null,"collapse":"open","preview_url":null,"versioning":false}	{"hidden":false}	\N	\N
36	37	directus_collections	subjects	{"hidden":true,"collection":"subjects"}	{"hidden":true,"collection":"subjects"}	\N	\N
37	38	directus_collections	subjects	{"collection":"subjects","icon":null,"note":null,"display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":null,"collapse":"open","preview_url":null,"versioning":false}	{"hidden":false}	\N	\N
38	39	directus_collections	subjects	{"collection":"subjects","icon":null,"note":"stores all teh subjects ","display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":null,"collapse":"open","preview_url":null,"versioning":false}	{"note":"stores all teh subjects "}	\N	\N
39	40	directus_collections	subject_study_levels	{"collection":"subject_study_levels","icon":null,"note":"study levels of the site ","display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":null,"collapse":"open","preview_url":null,"versioning":false}	{"note":"study levels of the site "}	\N	\N
40	41	directus_collections	specializations	{"collection":"specializations","icon":null,"note":"specilaization of students ","display_template":null,"hidden":false,"singleton":false,"translations":null,"archive_field":null,"archive_app_filter":true,"archive_value":null,"unarchive_value":null,"sort_field":null,"accountability":"all","color":null,"item_duplication_fields":null,"sort":null,"collapse":"open","preview_url":null,"versioning":false}	{"note":"specilaization of students "}	\N	\N
41	42	directus_fields	17	{"special":null,"field":"created_at"}	{"special":null,"field":"created_at"}	\N	\N
42	43	directus_fields	18	{"special":["uuid"],"field":"id"}	{"special":["uuid"],"field":"id"}	\N	\N
43	44	directus_fields	18	{"id":18,"field":"id","special":["uuid"],"interface":null,"options":null,"display":null,"display_options":null,"readonly":true,"hidden":true,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"subjects","field":"id","interface":null,"readonly":true,"hidden":true}	\N	\N
44	45	directus_fields	19	{"special":null,"field":"name"}	{"special":null,"field":"name"}	\N	\N
45	46	directus_fields	19	{"id":19,"field":"name","special":null,"interface":null,"options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":true,"validation":null,"validation_message":null,"searchable":true}	{"collection":"subjects","field":"name","required":true}	\N	\N
46	47	directus_fields	20	{"special":null,"field":"icon_key"}	{"special":null,"field":"icon_key"}	\N	\N
47	49	directus_fields	2	{"id":2,"field":"id","special":["uuid"],"interface":null,"options":null,"display":null,"display_options":null,"readonly":true,"hidden":true,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":false}	{"collection":"countries","field":"id","readonly":true,"hidden":true,"searchable":false}	\N	\N
48	50	directus_fields	3	{"id":3,"field":"name","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":true,"validation":null,"validation_message":null,"searchable":false}	{"collection":"countries","field":"name","interface":"input","required":true,"searchable":false}	\N	\N
49	51	directus_fields	4	{"id":4,"field":"slug","special":null,"interface":"input","options":{"slug":true},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":true,"validation":null,"validation_message":null,"searchable":false}	{"collection":"countries","field":"slug","interface":"input","options":{"slug":true},"required":true,"searchable":false}	\N	\N
50	52	directus_fields	5	{"id":5,"field":"country_code","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":false}	{"collection":"countries","field":"country_code","interface":"input","searchable":false}	\N	\N
51	53	directus_fields	6	{"id":6,"field":"description","special":null,"interface":"input-multiline","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"countries","field":"description","interface":"input-multiline"}	\N	\N
52	54	directus_fields	7	{"id":7,"field":"status","special":null,"interface":"select-dropdown","options":{"choices":[{"text":"draft","value":"draft"},{"text":"pending_review","value":"pending_review"},{"text":"published","value":"published"},{"text":"archieved","value":"archieved"}]},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"countries","field":"status","interface":"select-dropdown","options":{"choices":[{"text":"draft","value":"draft"},{"text":"pending_review","value":"pending_review"},{"text":"published","value":"published"},{"text":"archieved","value":"archieved"}]}}	\N	\N
53	55	directus_fields	7	{"id":7,"field":"status","special":null,"interface":"select-dropdown","options":{"choices":[{"text":"draft","value":"draft"},{"text":"pending_review","value":"pending_review"},{"text":"published","value":"published"},{"text":"archieved","value":"archieved"}]},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":true,"validation":null,"validation_message":null,"searchable":true}	{"collection":"countries","field":"status","required":true}	\N	\N
54	56	directus_fields	8	{"id":8,"field":"display_order","special":null,"interface":null,"options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":false}	{"collection":"countries","field":"display_order","searchable":false}	\N	\N
55	57	directus_fields	9	{"id":9,"field":"created_at","special":["date-created","date-updated"],"interface":"datetime","options":null,"display":null,"display_options":null,"readonly":true,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"countries","field":"created_at","interface":"datetime","readonly":true}	\N	\N
56	58	directus_fields	10	{"id":10,"field":"updated_at","special":["date-created","date-updated"],"interface":"datetime","options":null,"display":null,"display_options":null,"readonly":true,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"countries","field":"updated_at","interface":"datetime","readonly":true}	\N	\N
57	59	countries	27df52ab-b269-4d6a-9151-c80e746565d7	{"name":"United States of America ","slug":"usa","country_code":"US","description":"xyzzzz"}	{"name":"United States of America ","slug":"usa","country_code":"US","description":"xyzzzz"}	\N	\N
58	60	directus_fields	18	{"id":18,"field":"id","special":["uuid"],"interface":"input","options":null,"display":null,"display_options":null,"readonly":true,"hidden":true,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"subjects","field":"id","interface":"input"}	\N	\N
161	165	study_levels	38daafc4-ca6b-4511-9bbf-6fa2644130c8	{"name":"Pgdm","status":"published","display_order":7,"description":"<p>xyz jhssdhskdskjks</p>","slug":"pg-dm"}	{"name":"Pgdm","status":"published","display_order":7,"description":"<p>xyz jhssdhskdskjks</p>","slug":"pg-dm"}	\N	\N
59	61	directus_fields	19	{"id":19,"field":"name","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":true,"validation":null,"validation_message":null,"searchable":true}	{"collection":"subjects","field":"name","interface":"input"}	\N	\N
60	62	directus_fields	20	{"id":20,"field":"icon_key","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"subjects","field":"icon_key","interface":"input"}	\N	\N
61	63	directus_fields	21	{"special":null,"field":"slug"}	{"special":null,"field":"slug"}	\N	\N
62	64	directus_fields	21	{"id":21,"field":"slug","special":null,"interface":"input","options":{"slug":true},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":true,"validation":null,"validation_message":null,"searchable":true}	{"collection":"subjects","field":"slug","interface":"input","options":{"slug":true},"required":true}	\N	\N
63	65	directus_fields	22	{"special":null,"field":"description"}	{"special":null,"field":"description"}	\N	\N
64	66	directus_fields	22	{"id":22,"field":"description","special":null,"interface":"input-multiline","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"subjects","field":"description","interface":"input-multiline"}	\N	\N
65	67	directus_fields	23	{"special":null,"field":"status"}	{"special":null,"field":"status"}	\N	\N
66	68	directus_fields	23	{"id":23,"field":"status","special":null,"interface":"select-dropdown","options":{"choices":[{"text":"draft","value":"draft"},{"text":"pending_review","value":"pending_review"},{"text":"published","value":"published"},{"text":"archieved","value":"archieved"}]},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"subjects","field":"status","interface":"select-dropdown","options":{"choices":[{"text":"draft","value":"draft"},{"text":"pending_review","value":"pending_review"},{"text":"published","value":"published"},{"text":"archieved","value":"archieved"}]}}	\N	\N
67	69	directus_fields	24	{"special":null,"field":"display_order"}	{"special":null,"field":"display_order"}	\N	\N
68	70	directus_fields	24	{"id":24,"field":"display_order","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"subjects","field":"display_order","interface":"input"}	\N	\N
69	71	directus_fields	25	{"special":["uuid"],"field":"created_by"}	{"special":["uuid"],"field":"created_by"}	\N	\N
70	72	directus_fields	17	{"id":17,"field":"created_at","special":null,"interface":"datetime","options":null,"display":null,"display_options":null,"readonly":true,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"subjects","field":"created_at","interface":"datetime","readonly":true}	\N	\N
71	73	directus_fields	26	{"special":null,"field":"updated_at"}	{"special":null,"field":"updated_at"}	\N	\N
72	74	directus_fields	26	{"id":26,"field":"updated_at","special":null,"interface":"datetime","options":null,"display":null,"display_options":null,"readonly":true,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"subjects","field":"updated_at","interface":"datetime","readonly":true}	\N	\N
73	75	directus_fields	27	{"special":null,"field":"published_at"}	{"special":null,"field":"published_at"}	\N	\N
74	76	directus_fields	27	{"id":27,"field":"published_at","special":null,"interface":"datetime","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"subjects","field":"published_at","interface":"datetime"}	\N	\N
75	77	directus_fields	28	{"special":["uuid"],"field":"updated_by"}	{"special":["uuid"],"field":"updated_by"}	\N	\N
76	78	directus_fields	28	{"id":28,"field":"updated_by","special":["uuid"],"interface":"select-dropdown-m2o","options":{"template":"{{first_name}} {{last_name}}"},"display":null,"display_options":null,"readonly":true,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"subjects","field":"updated_by","interface":"select-dropdown-m2o","options":{"template":"{{first_name}} {{last_name}}"},"readonly":true}	\N	\N
77	79	directus_fields	29	{"special":["uuid"],"field":"reviewed_by"}	{"special":["uuid"],"field":"reviewed_by"}	\N	\N
78	80	directus_fields	29	{"id":29,"field":"reviewed_by","special":["uuid"],"interface":"select-dropdown-m2o","options":{"template":"{{first_name}} {{last_name}}"},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"subjects","field":"reviewed_by","interface":"select-dropdown-m2o","options":{"template":"{{first_name}} {{last_name}}"}}	\N	\N
79	81	subjects	d16938d0-d47b-4c82-9208-6c8b4f853c4d	{"name":"Engineering ","slug":"engineering","description":"Engineering education is broadly divided into core foundational subjects studied in the first year (common to most branches) and specialized subjects in later years","status":"published"}	{"name":"Engineering ","slug":"engineering","description":"Engineering education is broadly divided into core foundational subjects studied in the first year (common to most branches) and specialized subjects in later years","status":"published"}	\N	\N
80	82	subjects	2961fdfb-3e0a-4556-bf63-b609b5f5da89	{"name":"Medicine","slug":"medicine","description":"Medicine is the science and practice of diagnosing, treating, and preventing illness, injury, and disease to maintain human health"}	{"name":"Medicine","slug":"medicine","description":"Medicine is the science and practice of diagnosing, treating, and preventing illness, injury, and disease to maintain human health"}	\N	\N
163	168	directus_fields	63	{"special":null,"field":"entry_label"}	{"special":null,"field":"entry_label"}	\N	\N
81	83	subjects	2961fdfb-3e0a-4556-bf63-b609b5f5da89	{"id":"2961fdfb-3e0a-4556-bf63-b609b5f5da89","name":"Medicine","slug":"medicine","description":"Medicine is the science and practice of diagnosing, treating, and preventing illness, injury, and disease to maintain human health yes this is updating now .","icon_key":null,"status":"draft","display_order":0,"created_at":"2026-11-04T08:54:00.009Z","updated_at":"2026-11-04T08:57:19.129Z","published_at":null}	{"description":"Medicine is the science and practice of diagnosing, treating, and preventing illness, injury, and disease to maintain human health yes this is updating now .","updated_by":"6a46be53-0fda-4049-ac99-592e43454225","updated_at":"2026-11-04T08:57:19.129Z"}	\N	\N
82	84	subjects	3f4fc1dd-f807-46a2-a08b-76c8ea097a34	{"name":"Computer SCIENCE ","slug":"ai","description":"it is branch of cs where we larn abt computers."}	{"name":"Computer SCIENCE ","slug":"ai","description":"it is branch of cs where we larn abt computers."}	\N	\N
83	85	directus_fields	30	{"special":["uuid"],"field":"id"}	{"special":["uuid"],"field":"id"}	\N	\N
84	86	directus_fields	30	{"id":30,"field":"id","special":["uuid"],"interface":"input","options":null,"display":null,"display_options":null,"readonly":true,"hidden":true,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"specializations","field":"id","interface":"input","readonly":true,"hidden":true}	\N	\N
85	87	directus_fields	31	{"special":["uuid"],"field":"subject_id"}	{"special":["uuid"],"field":"subject_id"}	\N	\N
86	88	directus_fields	31	{"id":31,"field":"subject_id","special":["uuid"],"interface":"select-dropdown-m2o","options":{"template":"{{name}}"},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":true,"validation":null,"validation_message":null,"searchable":true}	{"collection":"specializations","field":"subject_id","interface":"select-dropdown-m2o","options":{"template":"{{name}}"},"required":true}	\N	\N
87	89	directus_fields	32	{"special":null,"field":"name"}	{"special":null,"field":"name"}	\N	\N
88	90	directus_fields	32	{"id":32,"field":"name","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":true,"validation":null,"validation_message":null,"searchable":true}	{"collection":"specializations","field":"name","interface":"input","required":true}	\N	\N
89	91	directus_fields	33	{"special":null,"field":"slug"}	{"special":null,"field":"slug"}	\N	\N
90	92	directus_fields	33	{"id":33,"field":"slug","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":true,"validation":null,"validation_message":null,"searchable":true}	{"collection":"specializations","field":"slug","interface":"input","required":true}	\N	\N
91	93	directus_fields	34	{"special":null,"field":"description"}	{"special":null,"field":"description"}	\N	\N
92	94	directus_fields	34	{"id":34,"field":"description","special":null,"interface":"input-multiline","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"specializations","field":"description","interface":"input-multiline"}	\N	\N
93	95	directus_fields	35	{"special":["cast-boolean"],"field":"is_featured"}	{"special":["cast-boolean"],"field":"is_featured"}	\N	\N
94	96	directus_fields	35	{"id":35,"field":"is_featured","special":["cast-boolean"],"interface":"boolean","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"specializations","field":"is_featured","interface":"boolean"}	\N	\N
95	97	directus_fields	36	{"special":null,"field":"status"}	{"special":null,"field":"status"}	\N	\N
96	98	directus_fields	36	{"id":36,"field":"status","special":null,"interface":"select-dropdown","options":{"choices":[{"text":"draft","value":"draft"},{"text":"pending_review","value":"pending_review"},{"text":"published","value":"published"},{"text":"archieved","value":"archieved"}]},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":true,"validation":null,"validation_message":null,"searchable":true}	{"collection":"specializations","field":"status","interface":"select-dropdown","options":{"choices":[{"text":"draft","value":"draft"},{"text":"pending_review","value":"pending_review"},{"text":"published","value":"published"},{"text":"archieved","value":"archieved"}]},"required":true}	\N	\N
97	99	directus_fields	37	{"special":null,"field":"display_order"}	{"special":null,"field":"display_order"}	\N	\N
98	100	directus_fields	37	{"id":37,"field":"display_order","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"specializations","field":"display_order","interface":"input"}	\N	\N
99	101	directus_fields	38	{"special":["uuid"],"field":"created_by"}	{"special":["uuid"],"field":"created_by"}	\N	\N
100	102	directus_fields	38	{"id":38,"field":"created_by","special":["uuid"],"interface":"select-dropdown-m2o","options":{"template":"{{first_name}} {{last_name}}"},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"specializations","field":"created_by","interface":"select-dropdown-m2o","options":{"template":"{{first_name}} {{last_name}}"}}	\N	\N
101	103	directus_fields	39	{"special":["uuid"],"field":"updated_by"}	{"special":["uuid"],"field":"updated_by"}	\N	\N
102	104	directus_fields	39	{"id":39,"field":"updated_by","special":["uuid"],"interface":"select-dropdown-m2o","options":{"template":"{{first_name}} {{last_name}}"},"display":null,"display_options":null,"readonly":true,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"specializations","field":"updated_by","interface":"select-dropdown-m2o","options":{"template":"{{first_name}} {{last_name}}"},"readonly":true}	\N	\N
103	105	directus_fields	40	{"special":["uuid"],"field":"reviewed_by"}	{"special":["uuid"],"field":"reviewed_by"}	\N	\N
104	106	directus_fields	40	{"id":40,"field":"reviewed_by","special":["uuid"],"interface":"select-dropdown-m2o","options":{"template":"{{first_name}} {{last_name}}"},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"specializations","field":"reviewed_by","interface":"select-dropdown-m2o","options":{"template":"{{first_name}} {{last_name}}"}}	\N	\N
105	107	directus_fields	41	{"special":null,"field":"created_at"}	{"special":null,"field":"created_at"}	\N	\N
106	108	directus_fields	41	{"id":41,"field":"created_at","special":null,"interface":"datetime","options":null,"display":null,"display_options":null,"readonly":true,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"specializations","field":"created_at","interface":"datetime","readonly":true}	\N	\N
107	109	directus_fields	42	{"special":null,"field":"updated_at"}	{"special":null,"field":"updated_at"}	\N	\N
108	110	directus_fields	42	{"id":42,"field":"updated_at","special":null,"interface":"datetime","options":null,"display":null,"display_options":null,"readonly":true,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"specializations","field":"updated_at","interface":"datetime","readonly":true}	\N	\N
109	111	directus_fields	43	{"special":null,"field":"published_at"}	{"special":null,"field":"published_at"}	\N	\N
110	112	directus_fields	43	{"id":43,"field":"published_at","special":null,"interface":"datetime","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"specializations","field":"published_at","interface":"datetime"}	\N	\N
111	113	directus_fields	44	{"sort":1,"interface":"list-o2m","special":["o2m"],"field":"subject_id"}	{"sort":1,"interface":"list-o2m","special":["o2m"],"field":"subject_id"}	\N	\N
112	115	directus_fields	45	{"sort":1,"interface":"list-o2m","special":["o2m"],"options":{"sort":null},"field":"Specialization"}	{"sort":1,"interface":"list-o2m","special":["o2m"],"options":{"sort":null},"field":"Specialization"}	\N	\N
113	116	directus_fields	46	{"special":["uuid"],"field":"id"}	{"special":["uuid"],"field":"id"}	\N	\N
114	117	directus_fields	46	{"id":46,"field":"id","special":["uuid"],"interface":"input","options":null,"display":null,"display_options":null,"readonly":true,"hidden":true,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"page_content","field":"id","interface":"input","readonly":true,"hidden":true}	\N	\N
115	118	directus_fields	47	{"special":null,"field":"page_key"}	{"special":null,"field":"page_key"}	\N	\N
116	119	directus_fields	47	{"id":47,"field":"page_key","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":true,"validation":null,"validation_message":null,"searchable":true}	{"collection":"page_content","field":"page_key","interface":"input","required":true}	\N	\N
117	120	directus_fields	48	{"special":null,"field":"section_key"}	{"special":null,"field":"section_key"}	\N	\N
118	121	directus_fields	48	{"id":48,"field":"section_key","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":true,"validation":null,"validation_message":null,"searchable":true}	{"collection":"page_content","field":"section_key","interface":"input","required":true}	\N	\N
119	122	directus_fields	49	{"special":null,"field":"content_key"}	{"special":null,"field":"content_key"}	\N	\N
120	123	directus_fields	49	{"id":49,"field":"content_key","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":true,"validation":null,"validation_message":null,"searchable":true}	{"collection":"page_content","field":"content_key","interface":"input","required":true}	\N	\N
121	124	directus_fields	50	{"special":["cast-json"],"field":"content_value"}	{"special":["cast-json"],"field":"content_value"}	\N	\N
122	125	directus_fields	50	{"id":50,"field":"content_value","special":["cast-json"],"interface":"input-code","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"page_content","field":"content_value","interface":"input-code"}	\N	\N
123	126	directus_fields	51	{"special":null,"field":"status"}	{"special":null,"field":"status"}	\N	\N
124	127	directus_fields	51	{"id":51,"field":"status","special":null,"interface":"select-dropdown","options":{"choices":[{"text":"draft","value":"draft"},{"text":"published","value":"published"},{"text":"pending_review","value":"pending_review"},{"text":"archived","value":"archived"}]},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"page_content","field":"status","interface":"select-dropdown","options":{"choices":[{"text":"draft","value":"draft"},{"text":"published","value":"published"},{"text":"pending_review","value":"pending_review"},{"text":"archived","value":"archived"}]}}	\N	\N
125	128	directus_fields	51	{"id":51,"field":"status","special":null,"interface":"select-dropdown","options":{"choices":[{"text":"draft","value":"draft"},{"text":"published","value":"published"},{"text":"pending_review","value":"pending_review"},{"text":"archived","value":"archived"}]},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":true,"validation":null,"validation_message":null,"searchable":true}	{"collection":"page_content","field":"status","required":true}	\N	\N
126	129	directus_fields	52	{"special":null,"field":"created_at"}	{"special":null,"field":"created_at"}	\N	\N
127	130	directus_fields	52	{"id":52,"field":"created_at","special":null,"interface":"datetime","options":null,"display":null,"display_options":null,"readonly":true,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"page_content","field":"created_at","interface":"datetime","readonly":true}	\N	\N
128	131	directus_fields	53	{"special":null,"field":"updated_at"}	{"special":null,"field":"updated_at"}	\N	\N
129	132	directus_fields	53	{"id":53,"field":"updated_at","special":null,"interface":"datetime","options":null,"display":null,"display_options":null,"readonly":true,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"page_content","field":"updated_at","interface":"datetime","readonly":true}	\N	\N
130	133	page_content	613e695c-2898-4aaa-ab84-76678721520b	{"id":"613e695c-2898-4aaa-ab84-76678721520b","page_key":"subjects","section_key":"hero","content_key":"title","content_value":"Find the field that fits you for your crrier","status":"published","created_at":"2026-11-05T10:51:07.518Z","updated_at":"2026-11-05T12:31:08.369Z"}	{"content_value":"Find the field that fits you for your crrier","updated_at":"2026-11-05T12:31:08.369Z"}	\N	\N
131	134	page_content	613e695c-2898-4aaa-ab84-76678721520b	{"id":"613e695c-2898-4aaa-ab84-76678721520b","page_key":"subjects","section_key":"hero","content_key":"title","content_value":"Find the field that fits you","status":"published","created_at":"2026-11-05T10:51:07.518Z","updated_at":"2026-11-05T12:32:04.172Z"}	{"content_value":"Find the field that fits you","updated_at":"2026-11-05T12:32:04.172Z"}	\N	\N
132	135	page_content	613e695c-2898-4aaa-ab84-76678721520b	{"id":"613e695c-2898-4aaa-ab84-76678721520b","page_key":"subjects","section_key":"hero","content_key":"title","content_value":"Find the field that fits you for you r carrier","status":"published","created_at":"2026-11-05T10:51:07.518Z","updated_at":"2026-11-05T12:44:37.734Z"}	{"content_value":"Find the field that fits you for you r carrier","updated_at":"2026-11-05T12:44:37.734Z"}	\N	\N
133	136	subjects	551051d3-3f41-429f-8b66-71611c7d5eb2	{"id":"551051d3-3f41-429f-8b66-71611c7d5eb2","name":"Computer Science & IT","slug":"computer-science-it","description":"Software, AI, data and the systems that run the modern world for our childeren of abroad.","icon_key":"code","status":"published","display_order":1,"created_at":"2026-11-05T11:18:56.891Z","updated_at":"2026-11-05T13:51:23.700Z","published_at":"2026-11-05T11:18:56.891Z"}	{"description":"Software, AI, data and the systems that run the modern world for our childeren of abroad.","updated_by":"6a46be53-0fda-4049-ac99-592e43454225","updated_at":"2026-11-05T13:51:23.700Z"}	\N	\N
134	137	subjects	551051d3-3f41-429f-8b66-71611c7d5eb2	{"id":"551051d3-3f41-429f-8b66-71611c7d5eb2","name":"Computer Science & IT","slug":"computer-science-it","description":"Software, AI, data and the systems that run the modern world.","icon_key":"code","status":"published","display_order":1,"created_at":"2026-11-05T11:18:56.891Z","updated_at":"2026-11-05T13:52:08.008Z","published_at":"2026-11-05T11:18:56.891Z"}	{"description":"Software, AI, data and the systems that run the modern world.","updated_by":"6a46be53-0fda-4049-ac99-592e43454225","updated_at":"2026-11-05T13:52:08.008Z"}	\N	\N
135	138	subjects	36d814c6-1ed9-4324-8c4d-48b9ab12b09b	{"name":"Dgital Marketing","slug":"dm","description":"Digital marketing is the practice of promoting brands, products, or services using the internet and electronic devices to reach target audiences and measure performance in real time"}	{"name":"Dgital Marketing","slug":"dm","description":"Digital marketing is the practice of promoting brands, products, or services using the internet and electronic devices to reach target audiences and measure performance in real time"}	\N	\N
136	139	subjects	36d814c6-1ed9-4324-8c4d-48b9ab12b09b	{"id":"36d814c6-1ed9-4324-8c4d-48b9ab12b09b","name":"Dgital Marketing","slug":"dm","description":"Digital marketing is the practice of promoting brands, products, or services using the internet and electronic devices to reach target audiences and measure performance in real time","icon_key":null,"status":"draft","display_order":11,"created_at":"2026-11-05T13:59:44.272Z","updated_at":"2026-11-05T14:01:09.611Z","published_at":null}	{"display_order":11,"updated_by":"6a46be53-0fda-4049-ac99-592e43454225","updated_at":"2026-11-05T14:01:09.611Z"}	\N	\N
137	140	subjects	36d814c6-1ed9-4324-8c4d-48b9ab12b09b	{"id":"36d814c6-1ed9-4324-8c4d-48b9ab12b09b","name":"Dgital Marketing","slug":"dm","description":"Digital marketing is the practice of promoting brands, products, or services using the internet and electronic devices to reach target audiences and measure performance in real time","icon_key":null,"status":"published","display_order":11,"created_at":"2026-11-05T13:59:44.272Z","updated_at":"2026-11-05T14:02:02.897Z","published_at":null}	{"status":"published","updated_by":"6a46be53-0fda-4049-ac99-592e43454225","updated_at":"2026-11-05T14:02:02.897Z"}	\N	\N
138	141	specializations	be5dc49f-e225-43da-bce1-d4fc633bfd54	{"name":"Business Management","slug":"bm","description":"Business management is the process of organizing, planning, leading, and controlling an organization's resources—such as people, money, and time—to achieve its goals efficiently","status":"published","display_order":1}	{"name":"Business Management","slug":"bm","description":"Business management is the process of organizing, planning, leading, and controlling an organization's resources—such as people, money, and time—to achieve its goals efficiently","status":"published","display_order":1}	\N	\N
139	143	subjects	9ddff52b-489d-4623-9e52-472183f23e75	{"name":"Business  Creation","slug":"business-creation","description":"1. A Business Creator is an entrepreneurial individual whose primary role is to build and launch new businesses or scale growing companies.\\n2. They maintain a significant and direct stake in the overall success of the enterprise, often acting as a founder, early team member, or key stakeholder.\\n3. Their core focus revolves around three main pillars: people (building teams), products (developing ideas), and processes (operating efficiently).\\n4. Unlike general support providers or external consultants, business creators stay deeply immersed within the company for the long term.\\n5. They identify market gaps, solve real consumer problems, and turn abstract concepts into tangible goods and services.\\n6. Many creators transition from building a personal content or audience brand into full-scale product companies and commercial ventures.\\n7. They take calculated financial and operational risks, navigating a competitive global landscape that demands constant adaptation.\\n8. Experienced business creators frequently \\"give back\\" by acting as mentors, advisors, or angel investors to early-stage talent and new startups.\\n9. Their efforts drive economic growth by generating employment opportunities and fostering innovation.\\n10. Ultimately, a business creator aims to build sustainable brands and create a lasting, positive impact on their industry and community.\\nWould you like me to tailor these 10 lines toward a specific type of business creator, such as a digital content creator or a tech startup founder?\\n","status":"published","display_order":12}	{"name":"Business  Creation","slug":"business-creation","description":"1. A Business Creator is an entrepreneurial individual whose primary role is to build and launch new businesses or scale growing companies.\\n2. They maintain a significant and direct stake in the overall success of the enterprise, often acting as a founder, early team member, or key stakeholder.\\n3. Their core focus revolves around three main pillars: people (building teams), products (developing ideas), and processes (operating efficiently).\\n4. Unlike general support providers or external consultants, business creators stay deeply immersed within the company for the long term.\\n5. They identify market gaps, solve real consumer problems, and turn abstract concepts into tangible goods and services.\\n6. Many creators transition from building a personal content or audience brand into full-scale product companies and commercial ventures.\\n7. They take calculated financial and operational risks, navigating a competitive global landscape that demands constant adaptation.\\n8. Experienced business creators frequently \\"give back\\" by acting as mentors, advisors, or angel investors to early-stage talent and new startups.\\n9. Their efforts drive economic growth by generating employment opportunities and fostering innovation.\\n10. Ultimately, a business creator aims to build sustainable brands and create a lasting, positive impact on their industry and community.\\nWould you like me to tailor these 10 lines toward a specific type of business creator, such as a digital content creator or a tech startup founder?\\n","status":"published","display_order":12}	\N	\N
162	167	study_levels	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	{"id":"9537c93a-8eb2-4066-9e6f-ad1e4b17512f","name":"Bachelor's","slug":"bachelors","description":"<p>Your first university degree, after finishing secondary school <strong>this is updated</strong> .</p>","duration":"3-4 years","status":"published","display_order":4,"created_at":"2026-11-07T06:30:26.963Z","updated_at":"2026-11-09T03:13:04.909Z"}	{"description":"<p>Your first university degree, after finishing secondary school <strong>this is updated</strong> .</p>","updated_at":"2026-11-09T03:13:04.909Z"}	\N	\N
140	144	subjects	9ddff52b-489d-4623-9e52-472183f23e75	{"id":"9ddff52b-489d-4623-9e52-472183f23e75","name":"Business  Creation","slug":"business-creation","description":"1. A Business Creator is an entrepreneurial individual whose primary role is to build and launch new businesses or scale growing companies.\\n2. They maintain a significant and direct stake in the overall success of the enterprise, often acting as a founder, early team member, or key stakeholder.\\n","icon_key":null,"status":"published","display_order":12,"created_at":"2026-11-06T17:14:28.791Z","updated_at":"2026-11-06T17:15:11.782Z","published_at":null}	{"description":"1. A Business Creator is an entrepreneurial individual whose primary role is to build and launch new businesses or scale growing companies.\\n2. They maintain a significant and direct stake in the overall success of the enterprise, often acting as a founder, early team member, or key stakeholder.\\n","updated_by":"6a46be53-0fda-4049-ac99-592e43454225","updated_at":"2026-11-06T17:15:11.782Z"}	\N	\N
141	145	specializations	c6973d9f-a1ce-4500-85dd-97ec3ccf00ba	{"name":"BNM Course","slug":"bnm-coiurse","description":"1. A Business Creator is an entrepreneurial individual whose primary role is to build and launch new businesses or scale growing companies.\\n2. They maintain a significant and direct stake in the overall success of the enterprise, often acting as a founder, early team member, or key stakeholder.\\n3. Their core focus revolves around three main pillars: people (building teams), products (developing ideas), and processes (operating efficiently).\\nto tangible ","status":"published","display_order":1}	{"name":"BNM Course","slug":"bnm-coiurse","description":"1. A Business Creator is an entrepreneurial individual whose primary role is to build and launch new businesses or scale growing companies.\\n2. They maintain a significant and direct stake in the overall success of the enterprise, often acting as a founder, early team member, or key stakeholder.\\n3. Their core focus revolves around three main pillars: people (building teams), products (developing ideas), and processes (operating efficiently).\\nto tangible ","status":"published","display_order":1}	\N	\N
142	146	directus_fields	54	{"special":null,"field":"duration"}	{"special":null,"field":"duration"}	\N	\N
143	147	directus_fields	55	{"special":["uuid"],"field":"id"}	{"special":["uuid"],"field":"id"}	\N	\N
144	148	directus_fields	55	{"id":55,"field":"id","special":["uuid"],"interface":null,"options":null,"display":null,"display_options":null,"readonly":true,"hidden":true,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"study_levels","field":"id","readonly":true,"hidden":true}	\N	\N
145	149	directus_fields	56	{"special":null,"field":"name"}	{"special":null,"field":"name"}	\N	\N
146	150	directus_fields	56	{"id":56,"field":"name","special":null,"interface":null,"options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":true,"validation":null,"validation_message":null,"searchable":true}	{"collection":"study_levels","field":"name","required":true}	\N	\N
147	151	directus_fields	57	{"special":null,"field":"slug"}	{"special":null,"field":"slug"}	\N	\N
148	152	directus_fields	58	{"special":null,"field":"description"}	{"special":null,"field":"description"}	\N	\N
149	153	directus_fields	58	{"id":58,"field":"description","special":null,"interface":"input-rich-text-html","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"study_levels","field":"description","interface":"input-rich-text-html"}	\N	\N
150	154	directus_fields	54	{"id":54,"field":"duration","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"study_levels","field":"duration","interface":"input"}	\N	\N
151	155	directus_fields	59	{"special":null,"field":"status"}	{"special":null,"field":"status"}	\N	\N
152	156	directus_fields	59	{"id":59,"field":"status","special":null,"interface":"select-dropdown","options":{"choices":[{"text":"draft","value":"draft"},{"text":"pending_review","value":"pending_review"},{"text":"published","value":"published"},{"text":"archived","value":"archived"}]},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"study_levels","field":"status","interface":"select-dropdown","options":{"choices":[{"text":"draft","value":"draft"},{"text":"pending_review","value":"pending_review"},{"text":"published","value":"published"},{"text":"archived","value":"archived"}]}}	\N	\N
153	157	directus_fields	60	{"special":null,"field":"display_order"}	{"special":null,"field":"display_order"}	\N	\N
154	158	directus_fields	60	{"id":60,"field":"display_order","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"study_levels","field":"display_order","interface":"input"}	\N	\N
155	159	directus_fields	61	{"special":null,"field":"created_at"}	{"special":null,"field":"created_at"}	\N	\N
156	160	directus_fields	61	{"id":61,"field":"created_at","special":null,"interface":"datetime","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"study_levels","field":"created_at","interface":"datetime"}	\N	\N
157	161	directus_fields	62	{"special":null,"field":"updated_at"}	{"special":null,"field":"updated_at"}	\N	\N
158	162	directus_fields	62	{"id":62,"field":"updated_at","special":null,"interface":"datetime","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"study_levels","field":"updated_at","interface":"datetime"}	\N	\N
159	163	page_content	613e695c-2898-4aaa-ab84-76678721520b	{"id":"613e695c-2898-4aaa-ab84-76678721520b","page_key":"subjects","section_key":"hero","content_key":"title","content_value":"Find the field that fits you for you","status":"published","created_at":"2026-11-05T10:51:07.518Z","updated_at":"2026-11-07T08:05:30.825Z"}	{"content_value":"Find the field that fits you for you","updated_at":"2026-11-07T08:05:30.825Z"}	\N	\N
160	164	subjects	449ded41-2db3-4675-b49d-7e0feb87206f	{"name":"xyz","description":"<p>hi hello&nbsp;</p>","status":"published","display_order":31,"slug":"x-yz"}	{"name":"xyz","description":"<p>hi hello&nbsp;</p>","status":"published","display_order":31,"slug":"x-yz"}	\N	\N
164	169	directus_fields	63	{"id":63,"field":"entry_label","special":null,"interface":"input","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"study_levels","field":"entry_label","interface":"input"}	\N	\N
165	170	directus_fields	64	{"special":["cast-json"],"field":"requirements"}	{"special":["cast-json"],"field":"requirements"}	\N	\N
166	171	directus_fields	64	{"id":64,"field":"requirements","special":["cast-json"],"interface":"list","options":null,"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"study_levels","field":"requirements","interface":"list"}	\N	\N
167	172	study_levels	6a18853c-07ce-47c2-a0a5-a5c4d1a3d2da	{"duration":"4","name":"PGDM","description":"<p>XYZZ</p>","status":"published","display_order":7,"entry_label":"Masters","slug":"pg"}	{"duration":"4","name":"PGDM","description":"<p>XYZZ</p>","status":"published","display_order":7,"entry_label":"Masters","slug":"pg"}	\N	\N
168	174	study_levels	6a18853c-07ce-47c2-a0a5-a5c4d1a3d2da	{"id":"6a18853c-07ce-47c2-a0a5-a5c4d1a3d2da","name":"PGDM","slug":"pg","description":"<p><strong class=\\"rQesXe MPyX\\" data-sfc-cp=\\"\\" data-sfc-root=\\"c\\" data-complete=\\"true\\"><span data-subtree=\\"aimfl,mfl\\">PGDM</span><!--TgQPHd|||[]--></strong> stands for <strong class=\\"rQesXe MPyX\\" data-sfc-cp=\\"\\" data-sfc-root=\\"c\\" data-complete=\\"true\\">Post Graduate Diploma in Management<!--TgQPHd|||[]--></strong>. It is <mark class=\\"b6AQX\\" data-wiz-attrbind=\\"class=cqWbw_o/cFwyDc\\" data-sfc-root=\\"c\\" data-ved=\\"2ahUKEwjFirTT0_qXAxWumuEIHQI_D54QuJAPegoIAggACAAIBRAB\\" data-complete=\\"true\\">a <strong class=\\"rQesXe MPyX\\" data-sfc-cp=\\"\\" data-sfc-root=\\"c\\" data-complete=\\"true\\">two-year, master's-level business management program<!--TgQPHd|||[]--></strong> offered by autonomous institutes approved by the All India Council for Technical Education (AICTE), rather than traditional universities</mark></p>","duration":"2-years","status":"published","display_order":7,"created_at":"2026-11-09T04:07:03.239Z","updated_at":"2026-11-09T10:15:07.355Z","entry_label":"Masters","requirements":null}	{"description":"<p><strong class=\\"rQesXe MPyX\\" data-sfc-cp=\\"\\" data-sfc-root=\\"c\\" data-complete=\\"true\\"><span data-subtree=\\"aimfl,mfl\\">PGDM</span><!--TgQPHd|||[]--></strong> stands for <strong class=\\"rQesXe MPyX\\" data-sfc-cp=\\"\\" data-sfc-root=\\"c\\" data-complete=\\"true\\">Post Graduate Diploma in Management<!--TgQPHd|||[]--></strong>. It is <mark class=\\"b6AQX\\" data-wiz-attrbind=\\"class=cqWbw_o/cFwyDc\\" data-sfc-root=\\"c\\" data-ved=\\"2ahUKEwjFirTT0_qXAxWumuEIHQI_D54QuJAPegoIAggACAAIBRAB\\" data-complete=\\"true\\">a <strong class=\\"rQesXe MPyX\\" data-sfc-cp=\\"\\" data-sfc-root=\\"c\\" data-complete=\\"true\\">two-year, master's-level business management program<!--TgQPHd|||[]--></strong> offered by autonomous institutes approved by the All India Council for Technical Education (AICTE), rather than traditional universities</mark></p>","duration":"2-years","updated_at":"2026-11-09T10:15:07.355Z"}	\N	\N
169	175	study_levels	6a18853c-07ce-47c2-a0a5-a5c4d1a3d2da	{"id":"6a18853c-07ce-47c2-a0a5-a5c4d1a3d2da","name":"PGDM","slug":"pg","description":"<p><strong class=\\"rQesXe MPyX\\" data-sfc-cp=\\"\\" data-sfc-root=\\"c\\" data-complete=\\"true\\"><span data-subtree=\\"aimfl,mfl\\">PGDM</span><!--TgQPHd|||[]--></strong> <em><strong>stands </strong></em>for <strong class=\\"rQesXe MPyX\\" data-sfc-cp=\\"\\" data-sfc-root=\\"c\\" data-complete=\\"true\\">Post Graduate Diploma in Management<!--TgQPHd|||[]--></strong>. It is <mark class=\\"b6AQX\\" data-wiz-attrbind=\\"class=cqWbw_o/cFwyDc\\" data-sfc-root=\\"c\\" data-ved=\\"2ahUKEwjFirTT0_qXAxWumuEIHQI_D54QuJAPegoIAggACAAIBRAB\\" data-complete=\\"true\\">a <strong class=\\"rQesXe MPyX\\" data-sfc-cp=\\"\\" data-sfc-root=\\"c\\" data-complete=\\"true\\">two-year, master's-level business management program<!--TgQPHd|||[]--></strong> offered by autonomous institutes approved by the All India Council for Technical Education (AICTE), rather than traditional universities</mark></p>","duration":"2-years","status":"published","display_order":7,"created_at":"2026-11-09T04:07:03.239Z","updated_at":"2026-11-09T10:17:40.704Z","entry_label":"Masters","requirements":null}	{"description":"<p><strong class=\\"rQesXe MPyX\\" data-sfc-cp=\\"\\" data-sfc-root=\\"c\\" data-complete=\\"true\\"><span data-subtree=\\"aimfl,mfl\\">PGDM</span><!--TgQPHd|||[]--></strong> <em><strong>stands </strong></em>for <strong class=\\"rQesXe MPyX\\" data-sfc-cp=\\"\\" data-sfc-root=\\"c\\" data-complete=\\"true\\">Post Graduate Diploma in Management<!--TgQPHd|||[]--></strong>. It is <mark class=\\"b6AQX\\" data-wiz-attrbind=\\"class=cqWbw_o/cFwyDc\\" data-sfc-root=\\"c\\" data-ved=\\"2ahUKEwjFirTT0_qXAxWumuEIHQI_D54QuJAPegoIAggACAAIBRAB\\" data-complete=\\"true\\">a <strong class=\\"rQesXe MPyX\\" data-sfc-cp=\\"\\" data-sfc-root=\\"c\\" data-complete=\\"true\\">two-year, master's-level business management program<!--TgQPHd|||[]--></strong> offered by autonomous institutes approved by the All India Council for Technical Education (AICTE), rather than traditional universities</mark></p>","updated_at":"2026-11-09T10:17:40.704Z"}	\N	\N
170	176	subject_sections	4ee5582d-591c-4001-b632-ea1d9a0fc654	{"id":"4ee5582d-591c-4001-b632-ea1d9a0fc654","section":"why","title":"Why study Architecture & Built Environment?","subtitle":null,"body":"<p>Architecture and the built environment deal with how places are imagined, designed, delivered and looked after over time. The field brings together creative disciplines such as <a href=\\"https://applicationabroad.com/subjects/architecture-built-environment/architecture/\\">Architecture</a>, <a href=\\"https://applicationabroad.com/subjects/architecture-built-environment/interior-architecture/\\">Interior Architecture</a> and <a href=\\"https://applicationabroad.com/subjects/architecture-built-environment/landscape-architecture/\\">Landscape Architecture</a> with technical and commercial ones such as <a href=\\"https://applicationabroad.com/subjects/architecture-built-environment/construction-management/\\">Construction Management</a>, <a href=\\"https://applicationabroad.com/subjects/architecture-built-environment/quantity-surveying/\\">Quantity Surveying</a> and <a href=\\"https://applicationabroad.com/subjects/architecture-built-environment/real-estate/\\">Real Estate</a>.</p>\\n<p>Students learn to work across scales, from the detail of a building junction to the layout of a neighbourhood. Design studios sit alongside structures, building services, materials, law, cost and planning policy, so every proposal is tested against how it will be built, used and paid for. <a href=\\"https://applicationabroad.com/subjects/architecture-built-environment/urban-planning/\\">Urban Planning</a> and <a href=\\"https://applicationabroad.com/subjects/architecture-built-environment/heritage-conservation/\\">Heritage Conservation</a> extend the same thinking to cities and historic places.</p>\\n<p>The subject suits people who enjoy drawing and problem-solving as much as organising people and information. Building codes, climates and planning systems differ between countries, so studying abroad can offer a useful comparative view. Some programmes are linked to professional accreditation, which is worth checking for the country where you plan to work.</p>","url":null,"is_sponsored":false,"status":"published","display_order":1,"created_at":"2026-11-09T19:49:48.941Z","updated_at":"2026-11-09T20:26:26.105Z"}	{"body":"<p>Architecture and the built environment deal with how places are imagined, designed, delivered and looked after over time. The field brings together creative disciplines such as <a href=\\"https://applicationabroad.com/subjects/architecture-built-environment/architecture/\\">Architecture</a>, <a href=\\"https://applicationabroad.com/subjects/architecture-built-environment/interior-architecture/\\">Interior Architecture</a> and <a href=\\"https://applicationabroad.com/subjects/architecture-built-environment/landscape-architecture/\\">Landscape Architecture</a> with technical and commercial ones such as <a href=\\"https://applicationabroad.com/subjects/architecture-built-environment/construction-management/\\">Construction Management</a>, <a href=\\"https://applicationabroad.com/subjects/architecture-built-environment/quantity-surveying/\\">Quantity Surveying</a> and <a href=\\"https://applicationabroad.com/subjects/architecture-built-environment/real-estate/\\">Real Estate</a>.</p>\\n<p>Students learn to work across scales, from the detail of a building junction to the layout of a neighbourhood. Design studios sit alongside structures, building services, materials, law, cost and planning policy, so every proposal is tested against how it will be built, used and paid for. <a href=\\"https://applicationabroad.com/subjects/architecture-built-environment/urban-planning/\\">Urban Planning</a> and <a href=\\"https://applicationabroad.com/subjects/architecture-built-environment/heritage-conservation/\\">Heritage Conservation</a> extend the same thinking to cities and historic places.</p>\\n<p>The subject suits people who enjoy drawing and problem-solving as much as organising people and information. Building codes, climates and planning systems differ between countries, so studying abroad can offer a useful comparative view. Some programmes are linked to professional accreditation, which is worth checking for the country where you plan to work.</p>","updated_at":"2026-11-09T20:26:26.105Z"}	\N	\N
171	177	subject_sections	44deb987-60a3-4d31-a5ee-60e6b8cb06ff	{"section":"why","body":"<p><span data-subtree=\\"aimfl,mfl\\">A bachelor's degree </span><mark class=\\"b6AQX\\" data-wiz-attrbind=\\"class=JVJwCd_o/cFwyDc\\" data-sfc-root=\\"c\\" data-ved=\\"2ahUKEwi6guKX4PuXAxUcT2wGHcElPLcQuJAPegoIAggACAAICRAB\\" data-complete=\\"true\\">unlocks a wider range of career opportunities, higher earning potential, and faster professional advancement compared to a high school diploma.</mark></p>","status":"published","title":"Bachelors"}	{"section":"why","body":"<p><span data-subtree=\\"aimfl,mfl\\">A bachelor's degree </span><mark class=\\"b6AQX\\" data-wiz-attrbind=\\"class=JVJwCd_o/cFwyDc\\" data-sfc-root=\\"c\\" data-ved=\\"2ahUKEwi6guKX4PuXAxUcT2wGHcElPLcQuJAPegoIAggACAAICRAB\\" data-complete=\\"true\\">unlocks a wider range of career opportunities, higher earning potential, and faster professional advancement compared to a high school diploma.</mark></p>","status":"published","title":"Bachelors"}	\N	\N
179	185	subject_sections	cd233e55-6cc8-44be-8202-b0b0f23fc5b2	{"id":"cd233e55-6cc8-44be-8202-b0b0f23fc5b2","section":"about","title":"About Foundation in Agriculture & Environmental Sciences","subtitle":null,"body":"<p>hit this is my new content&nbsp;</p>","url":null,"is_sponsored":false,"status":"published","display_order":1,"created_at":"2026-11-09T20:35:23.636Z","updated_at":"2026-11-10T08:58:46.735Z"}	{"subject_id":"f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa","body":"<p>hit this is my new content&nbsp;</p>","updated_at":"2026-11-10T08:58:46.735Z"}	\N	\N
172	178	subject_sections	ab2f0545-8945-48e0-a1f0-4a798339ff64	{"id":"ab2f0545-8945-48e0-a1f0-4a798339ff64","section":"about","title":"About Architecture","subtitle":null,"body":"<p><span data-subtree=\\"aimfl,mfl\\"><strong>Architecture </strong>is </span><mark class=\\"b6AQX\\" data-wiz-attrbind=\\"class=NT2wub_5f/cFwyDc\\" data-sfc-root=\\"c\\" data-ved=\\"2ahUKEwji-J30yPyXAxVPTWwGHaoCDZYQuJAPegoIAggACAAIDBAB\\">the art and science of designing, planning, and constructing buildings and physical structures<!--TgQPHd|||[[[null,null,null,null,null,null,null,null,null,null,null,null,[247864,null,0]]]]--></mark>. It sits at the intersection of creative expression and structural engineering, shaping how people live, work, and interact with their environments</p>","url":null,"is_sponsored":false,"status":"published","display_order":1,"created_at":"2026-11-09T20:52:28.106Z","updated_at":"2026-11-10T04:32:56.806Z"}	{"body":"<p><span data-subtree=\\"aimfl,mfl\\"><strong>Architecture </strong>is </span><mark class=\\"b6AQX\\" data-wiz-attrbind=\\"class=NT2wub_5f/cFwyDc\\" data-sfc-root=\\"c\\" data-ved=\\"2ahUKEwji-J30yPyXAxVPTWwGHaoCDZYQuJAPegoIAggACAAIDBAB\\">the art and science of designing, planning, and constructing buildings and physical structures<!--TgQPHd|||[[[null,null,null,null,null,null,null,null,null,null,null,null,[247864,null,0]]]]--></mark>. It sits at the intersection of creative expression and structural engineering, shaping how people live, work, and interact with their environments</p>","updated_at":"2026-11-10T04:32:56.806Z"}	\N	\N
173	179	subject_sections	f104f072-fe15-4570-87aa-e2966b96686c	{"id":"f104f072-fe15-4570-87aa-e2966b96686c","section":"why","title":"Why study Architecture?","subtitle":null,"body":"<p><strong class=\\"rQesXe MPyX\\" data-sfc-cp=\\"\\" data-sfc-root=\\"c\\" data-complete=\\"true\\" data-processed=\\"true\\"><span data-subtree=\\"aimfl\\" data-processed=\\"true\\">Architecture is the profound intersection of creative expression, technical innovation, and human experience.</span><!--TgQPHd|||[]--></strong> It is the art and science of shaping the physical environments that define how we live, work, connect, and evolve. To study architecture is to become a visionary problem solver, transforming complex spatial challenges into sustainable, beautiful, and highly functional realities. By blending design thinking with historical context and structural engineering, architects do not just build structures&mdash;they design the future, leaving a tangible, lasting legacy on communities and the natural world.</p>","url":null,"is_sponsored":false,"status":"published","display_order":1,"created_at":"2026-11-09T20:52:28.106Z","updated_at":"2026-11-10T04:35:09.405Z"}	{"body":"<p><strong class=\\"rQesXe MPyX\\" data-sfc-cp=\\"\\" data-sfc-root=\\"c\\" data-complete=\\"true\\" data-processed=\\"true\\"><span data-subtree=\\"aimfl\\" data-processed=\\"true\\">Architecture is the profound intersection of creative expression, technical innovation, and human experience.</span><!--TgQPHd|||[]--></strong> It is the art and science of shaping the physical environments that define how we live, work, connect, and evolve. To study architecture is to become a visionary problem solver, transforming complex spatial challenges into sustainable, beautiful, and highly functional realities. By blending design thinking with historical context and structural engineering, architects do not just build structures&mdash;they design the future, leaving a tangible, lasting legacy on communities and the natural world.</p>","updated_at":"2026-11-10T04:35:09.405Z"}	\N	\N
174	180	directus_fields	22	{"id":22,"field":"description","special":null,"interface":"input-rich-text-html","options":{"toolbar":["undo","redo","bold","italic","underline","subscript","superscript","fontfamily","fontsize","h1","h2","h3","h4","h5","h6","customPre","alignleft","aligncenter","alignright","alignjustify","alignnone","indent","outdent","numlist","bullist","removeformat","cut","copy","paste","remove","link","selectall","blockquote"]},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"subjects","field":"description","options":{"toolbar":["undo","redo","bold","italic","underline","subscript","superscript","fontfamily","fontsize","h1","h2","h3","h4","h5","h6","customPre","alignleft","aligncenter","alignright","alignjustify","alignnone","indent","outdent","numlist","bullist","removeformat","cut","copy","paste","remove","link","selectall","blockquote"]}}	\N	\N
175	181	directus_fields	58	{"id":58,"field":"description","special":null,"interface":"input-rich-text-html","options":{"toolbar":["undo","redo","bold","italic","underline","subscript","superscript","fontfamily","fontsize","h1","h2","h3","h4","h5","h6","alignleft","aligncenter","alignright","alignjustify","alignnone","numlist","bullist","removeformat","cut","copy","paste","remove","selectall","blockquote","customLink","customImage","customMedia","hr","fullscreen","code"]},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"study_levels","field":"description","options":{"toolbar":["undo","redo","bold","italic","underline","subscript","superscript","fontfamily","fontsize","h1","h2","h3","h4","h5","h6","alignleft","aligncenter","alignright","alignjustify","alignnone","numlist","bullist","removeformat","cut","copy","paste","remove","selectall","blockquote","customLink","customImage","customMedia","hr","fullscreen","code"]}}	\N	\N
176	182	directus_fields	34	{"id":34,"field":"description","special":null,"interface":"input-rich-text-html","options":{"toolbar":["undo","redo","bold","italic","underline","strikethrough","subscript","superscript","fontfamily","fontsize","h1","h2","h3","h4","h5","h6","alignleft","aligncenter","alignright","alignjustify","alignnone","numlist","bullist","removeformat","cut","copy","paste","link","remove","selectall","hr","ltr rtl"]},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"specializations","field":"description","options":{"toolbar":["undo","redo","bold","italic","underline","strikethrough","subscript","superscript","fontfamily","fontsize","h1","h2","h3","h4","h5","h6","alignleft","aligncenter","alignright","alignjustify","alignnone","numlist","bullist","removeformat","cut","copy","paste","link","remove","selectall","hr","ltr rtl"]}}	\N	\N
177	183	directus_fields	22	{"id":22,"field":"description","special":null,"interface":"input-rich-text-html","options":{"toolbar":["undo","redo","bold","italic","underline","subscript","superscript","fontfamily","fontsize","h1","h2","h3","h4","h5","h6","customPre","alignleft","aligncenter","alignright","alignjustify","alignnone","indent","outdent","numlist","bullist","removeformat","cut","copy","paste","remove","selectall","link","blockquote","fullscreen"]},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"subjects","field":"description","options":{"toolbar":["undo","redo","bold","italic","underline","subscript","superscript","fontfamily","fontsize","h1","h2","h3","h4","h5","h6","customPre","alignleft","aligncenter","alignright","alignjustify","alignnone","indent","outdent","numlist","bullist","removeformat","cut","copy","paste","remove","selectall","link","blockquote","fullscreen"]}}	\N	\N
178	184	directus_fields	34	{"id":34,"field":"description","special":null,"interface":"input-rich-text-html","options":{"toolbar":["undo","redo","bold","italic","underline","strikethrough","subscript","superscript","fontfamily","fontsize","h1","h2","h3","h4","h5","h6","alignleft","aligncenter","alignright","alignjustify","alignnone","numlist","bullist","removeformat","cut","copy","paste","remove","link","selectall","hr","fullscreen","ltr rtl"]},"display":null,"display_options":null,"readonly":false,"hidden":false,"sort":null,"width":"full","translations":null,"note":null,"conditions":null,"required":false,"validation":null,"validation_message":null,"searchable":true}	{"collection":"specializations","field":"description","options":{"toolbar":["undo","redo","bold","italic","underline","strikethrough","subscript","superscript","fontfamily","fontsize","h1","h2","h3","h4","h5","h6","alignleft","aligncenter","alignright","alignjustify","alignnone","numlist","bullist","removeformat","cut","copy","paste","remove","link","selectall","hr","fullscreen","ltr rtl"]}}	\N	\N
\.


--
-- Data for Name: directus_roles; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_roles (id, name, icon, description, parent) FROM stdin;
5fe778c9-7d2e-4178-b3d8-7a656c2abf9a	Administrator	verified	$t:admin_description	\N
\.


--
-- Data for Name: directus_sessions; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_sessions (token, "user", expires, ip, user_agent, share, origin, next_token) FROM stdin;
VRbDhtLB3-vqeK6j_RJ0TQvtSi3nLC3rjTP2rRydExo9Vk3ibrJ6zJ9bi6eWZAh2	6a46be53-0fda-4049-ac99-592e43454225	2026-11-10 09:11:37.307+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	\N	http://localhost:8055	v4IQ1FP5CJMnVn5FDdxXAxiLvY5Kj417oSUmhgdD5p63UdsBaD7bjSdYYpvTJGIt
v4IQ1FP5CJMnVn5FDdxXAxiLvY5Kj417oSUmhgdD5p63UdsBaD7bjSdYYpvTJGIt	6a46be53-0fda-4049-ac99-592e43454225	2026-11-11 09:11:27.306+00	172.18.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36	\N	http://localhost:8055	\N
\.


--
-- Data for Name: directus_settings; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_settings (id, project_name, project_url, project_color, project_logo, public_foreground, public_background, public_note, auth_login_attempts, auth_password_policy, storage_asset_transform, storage_asset_presets, custom_css, storage_default_folder, basemaps, mapbox_key, module_bar, project_descriptor, default_language, custom_aspect_ratios, public_favicon, default_appearance, default_theme_light, theme_light_overrides, default_theme_dark, theme_dark_overrides, report_error_url, report_bug_url, report_feature_url, public_registration, public_registration_verify_email, public_registration_role, public_registration_email_filter, visual_editor_urls, project_id, mcp_enabled, mcp_allow_deletes, mcp_prompts_collection, mcp_system_prompt_enabled, mcp_system_prompt, project_owner, project_usage, org_name, product_updates, project_status, ai_openai_api_key, ai_anthropic_api_key, ai_system_prompt, ai_google_api_key, ai_openai_compatible_api_key, ai_openai_compatible_base_url, ai_openai_compatible_name, ai_openai_compatible_models, ai_openai_compatible_headers, ai_openai_allowed_models, ai_anthropic_allowed_models, ai_google_allowed_models, collaborative_editing_enabled) FROM stdin;
1	Directus	\N	#6644FF	\N	\N	\N	\N	25	\N	all	\N	\N	\N	\N	\N	\N	\N	en-US	\N	\N	auto	\N	\N	\N	\N	\N	\N	\N	f	t	\N	\N	\N	01a19beb-76e4-7174-884f-c6470cff8f61	f	f	\N	t	\N	tech@universta.com	commercial	Universta	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	["gpt-5-nano","gpt-5-mini","gpt-5"]	["claude-haiku-4-5","claude-sonnet-4-5"]	["gemini-3-pro-preview","gemini-3-flash-preview","gemini-2.5-pro","gemini-2.5-flash"]	f
\.


--
-- Data for Name: directus_shares; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_shares (id, name, collection, item, role, password, user_created, date_created, date_start, date_end, times_used, max_uses) FROM stdin;
\.


--
-- Data for Name: directus_translations; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_translations (id, language, key, value) FROM stdin;
\.


--
-- Data for Name: directus_users; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_users (id, first_name, last_name, email, password, location, title, description, tags, avatar, language, tfa_secret, status, role, token, last_access, last_page, provider, external_identifier, auth_data, email_notifications, appearance, theme_dark, theme_light, theme_light_overrides, theme_dark_overrides, text_direction) FROM stdin;
6a46be53-0fda-4049-ac99-592e43454225	Admin	User	admin@example.com	$argon2id$v=19$m=65536,t=3,p=4$jZWFUjMCUdEkDsNRX8LBHg$B7dkOpnKZgi2OXTeGbMpgIqoVeMgPIWBsdDd4wNSVz8	\N	\N	\N	\N	\N	\N	\N	active	5fe778c9-7d2e-4178-b3d8-7a656c2abf9a	\N	2026-11-10 09:11:27.319+00	/content/subject_sections	default	\N	\N	t	\N	\N	\N	\N	\N	auto
\.


--
-- Data for Name: directus_versions; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.directus_versions (id, key, name, collection, item, hash, date_created, date_updated, user_created, user_updated, delta) FROM stdin;
\.


--
-- Data for Name: enquiries; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.enquiries (id, full_name, email, phone, preferred_country_id, planned_intake, source_page, status, assigned_to, internal_notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: page_content; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.page_content (id, page_key, section_key, content_key, content_value, status, created_at, updated_at) FROM stdin;
6d390ab5-d394-49a3-b14e-8151c526977a	subjects	hero	eyebrow	"SUBJECTS & SPECIALIZATIONS"	published	2026-11-05 10:51:07.518255+00	\N
2c3d8e00-0810-467b-b5ca-72686ce471d3	subjects	hero	intro	"Explore {count} major fields and dozens of specializations. Every subject guide shows careers, typical modules, top universities and how degrees differ by study level."	published	2026-11-05 10:51:07.518255+00	\N
d4dce2cb-62c9-4398-b766-66313256c0e7	subjects	search	placeholder	"Search subjects or specializations..."	published	2026-11-05 10:51:07.518255+00	\N
98f02bde-f40a-4907-8527-304f0a3c8e7f	subjects	search	button	"Search"	published	2026-11-05 10:51:07.518255+00	\N
de29975b-8511-4095-8650-bc27bcbaadb5	subjects	filters	title	"Filters"	published	2026-11-05 10:51:07.518255+00	\N
5cb7ccb4-a34e-4685-97d7-d313ff33fbe0	subjects	list	empty_message	"No subjects match your search. Try a different word or clear the filters."	published	2026-11-05 10:51:07.518255+00	\N
3e0e6852-937e-442f-b1dd-a49e95ac2feb	subject-detail	overview	title	"Overview"	published	2026-11-05 13:39:41.575763+00	\N
afef5c57-84a3-4946-a0a8-1302219c893b	subject-detail	specializations	title	"Specializations"	published	2026-11-05 13:39:41.575763+00	\N
17da6400-f8d9-48a6-9364-1d0390c4a23c	subject-detail	specializations	intro	"Narrow your focus. Each specialization has its own modules, universities and career paths."	published	2026-11-05 13:39:41.575763+00	\N
1c77e5f8-f5a8-4d09-9e04-6e02e6bd50e3	subject-detail	study_levels	title	"Study levels"	published	2026-11-05 13:39:41.575763+00	\N
49366b9f-b28a-414b-98ea-40317ba7cd21	subject-detail	study_levels	intro	"Choose a level to see entry requirements, programmes and costs."	published	2026-11-05 13:39:41.575763+00	\N
613e695c-2898-4aaa-ab84-76678721520b	subjects	hero	title	"Find the field that fits you for you"	published	2026-11-05 10:51:07.518255+00	2026-11-07 08:05:30.825+00
\.


--
-- Data for Name: popular_searches; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.popular_searches (id, label, target_type, subject_id, specialization_id, display_order, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: specializations; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.specializations (id, subject_id, name, slug, description, is_featured, status, display_order, created_by, updated_by, reviewed_by, created_at, updated_at, published_at) FROM stdin;
232714c5-24eb-480b-ac4b-6d6ad4a7b638	7ef86a94-d348-4493-8cdd-5d8b45e1a158	STEM Education	stem-education	\N	f	published	35	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c6505fa6-068e-489d-9294-6e7c861e4d14	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Agribusiness	agribusiness	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3f41fb69-8281-49dc-96c8-758779e12c23	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Agriculture	agriculture	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
66c3fcfe-f8d0-4deb-8416-48941f9ab0bf	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Agricultural Economics	agricultural-economics	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f94e0637-17bf-4133-9570-8a6a8bb9ffff	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Agricultural Engineering	agricultural-engineering-agriculture-environmental-sciences	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6aff5dfb-971f-41b5-abc5-c5807ffa6285	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Agricultural Management	agricultural-management	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4e04b017-343c-459b-905d-870ecb8d5c2c	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Agricultural Science	agricultural-science	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7c4adfa6-3823-40ae-8821-3d4f8f3c7eb1	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Animal Science	animal-science-agriculture-environmental-sciences	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
17cec524-a972-414a-b290-5e359877cdca	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Aquaculture	aquaculture	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
981e3d68-6f31-4ca5-8ef4-6f09f0fbb91a	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Fisheries Science	fisheries-science	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f13541e3-e48a-49e8-9169-2485ba2f6690	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Food Science	food-science-agriculture-environmental-sciences	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c5bef499-6697-4eef-8367-e6097a241f90	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Food Technology	food-technology-agriculture-environmental-sciences	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
32739dc1-c6e1-4b84-8664-7e6488552d4d	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Forestry	forestry	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1d4ae2b7-fc2c-4104-881a-59027e37e056	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Horticulture	horticulture	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
135edfb6-d0ab-42a8-a057-07675ae482be	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Plant Science	plant-science-agriculture-environmental-sciences	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1c9923f0-a317-4f86-9348-d28788a3e6ff	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Plant Biotechnology	plant-biotechnology	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
70eed122-dbf3-4a4a-9ba0-87ff084ffc8a	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Soil Science	soil-science	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
db14f811-c6d7-49bf-8992-5f538462ea79	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Crop Science	crop-science	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b867af9e-16d3-4e90-bb43-3cc5d8f5be32	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Crop Production	crop-production	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cfb8c166-77a3-40da-8f38-6ee5d589ecb8	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Animal Husbandry	animal-husbandry	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
29e34e9a-a630-42cf-9a11-c111ebe87b92	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Equine Studies	equine-studies	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
45872145-6523-418b-95b2-382dc2b31cad	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Viticulture & Winemaking	viticulture-winemaking	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
84b0b28f-cde5-4316-b672-80e160d08f6e	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Wildlife Conservation	wildlife-conservation	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5dd629a3-3d0b-41f7-aa97-e6b5d317b3e1	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Wildlife Management	wildlife-management	\N	f	published	23	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cd1cce29-555d-439a-b52c-0ebffd86558f	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Zoology	zoology-agriculture-environmental-sciences	\N	f	published	24	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7746b5e6-16df-46dd-b654-b4d0aa8759e0	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Environmental Science	environmental-science-agriculture-environmental-sciences	\N	f	published	25	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9b38afa9-ed35-4247-a719-0a14a1219ffd	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Environmental Management	environmental-management	\N	f	published	26	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e1eebe30-3bfa-406b-8467-97561fbe2858	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Environmental Engineering	environmental-engineering-agriculture-environmental-sciences	\N	f	published	27	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8473b45b-3e50-4300-a15d-0b575735c837	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Environmental Policy	environmental-policy	\N	f	published	28	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a4a65d01-72d3-438f-85d8-bddedbc85b71	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Environmental Sustainability	environmental-sustainability-agriculture-environmental-sciences	\N	f	published	29	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
43c82251-4eb3-4555-b6d4-be9cdfe4738f	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Climate Change	climate-change-agriculture-environmental-sciences	\N	f	published	30	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e183256d-649a-4617-b733-81979bbf6c14	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Climate Science	climate-science	\N	f	published	31	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6bb5f644-feb6-4293-9087-50c8426c2c71	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Conservation Biology	conservation-biology-agriculture-environmental-sciences	\N	f	published	32	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7d5af44e-75b5-4090-9f37-b0f5b6b53849	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Marine Biology	marine-biology-agriculture-environmental-sciences	\N	f	published	33	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6ebc52c8-433c-43b2-b2d4-4cc392ce3b03	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Marine Science	marine-science-agriculture-environmental-sciences	\N	f	published	34	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ffe9e25f-0559-425b-aec0-8cbeb8530772	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Oceanography	oceanography-agriculture-environmental-sciences	\N	f	published	35	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
799b0fa2-64a0-4b57-9ed6-c3a1a0627b1d	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Ecology	ecology-agriculture-environmental-sciences	\N	f	published	36	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
447fdbb1-c542-469a-b789-892501a01d39	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Biodiversity	biodiversity	\N	f	published	37	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
719b57d2-f87f-4276-bc93-377c0dd7f137	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Renewable Energy	renewable-energy-agriculture-environmental-sciences	\N	f	published	38	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a09a7065-aac0-4228-9b13-f319649620d8	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Sustainable Development	sustainable-development	\N	f	published	39	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
720af046-b8ee-44dc-b844-6cd4ef949c9a	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Sustainable Agriculture	sustainable-agriculture	\N	f	published	40	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e12a78f1-3e74-43a4-9246-bc77f332ee7b	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Natural Resource Management	natural-resource-management	\N	f	published	41	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
39b8ab77-85c6-424b-9fc0-ac22ea003558	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Water Management	water-management	\N	f	published	42	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
37110145-e512-444f-99b3-dcf5620eba5e	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Water Resources	water-resources	\N	f	published	43	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
74213fa3-c75e-4266-a2bd-66da0309d049	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Geology	geology-agriculture-environmental-sciences	\N	f	published	44	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
68b42b1e-8e56-45a5-81c5-7ebfb008c310	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Geoscience	geoscience	\N	f	published	45	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
93c8fa29-067d-4098-9eb6-891c0ef5d5e1	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Earth Sciences	earth-sciences	\N	f	published	46	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b910a05a-0e32-4648-ac1e-1407af3c89fb	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Architecture	architecture	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a0ab2e9b-d1fd-46e3-a146-707f161c5366	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Architectural Design	architectural-design	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2e6d06e0-835d-45f3-b801-e44d97d60e91	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Architectural Technology	architectural-technology	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3cc8fdd0-8044-48ed-a6f6-d2cce1bbf606	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Interior Architecture	interior-architecture	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a304ad3c-4d86-45be-8287-a7d37a04d44d	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Landscape Architecture	landscape-architecture	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b6ccb876-e110-45bb-88f3-a6ffe43949ca	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Urban Design	urban-design	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5285e39a-41fb-445d-a364-cdefdb21aea3	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Urban Planning	urban-planning	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ea5ba414-071a-40e1-a0eb-02f696a7ad95	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Regional Planning	regional-planning	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a37f67a9-cd57-47a8-85e6-c8c1f0e9ef80	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	City Planning	city-planning	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
337a103d-78f8-4f33-aa4f-1e9672560f92	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Property Management	property-management	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3f37dfbd-d9e8-4fbb-982a-7016426f3424	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Real Estate	real-estate	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a10ab517-dde2-4d23-a2d9-e43bb4054693	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Real Estate Management	real-estate-management-architecture-built-environment	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cad19021-be2a-46bd-ad28-6927ece40b15	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Construction Management	construction-management-architecture-built-environment	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1c28e409-68e5-451f-8eb1-ee002369d0b6	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Construction Project Management	construction-project-management	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d8665edd-0750-45b3-b38a-241b0f2b6024	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Quantity Surveying	quantity-surveying	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fb1e0c0f-f711-4d77-a279-bf6740e989be	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Building Surveying	building-surveying	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
59d9ebf1-5d43-4c7a-846c-f6a984af36d8	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Land Surveying	land-surveying	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d0b52931-ea0a-421d-8193-10ed7b8dd2bb	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Geomatics	geomatics	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a2af23e8-15fb-4c67-9a1b-9e8a646eb702	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Surveying	surveying	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
11fe7110-ee16-494c-ae19-e076c504b31f	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Civil Infrastructure	civil-infrastructure	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1ea48e0d-1494-449a-880a-f93cb4c61f20	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Building Services Engineering	building-services-engineering	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
246e24c0-0b61-4aed-9fdb-71ccdcea057a	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Sustainable Architecture	sustainable-architecture	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a1d47014-14cf-4481-b7a3-e149f13640cb	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Sustainable Construction	sustainable-construction	\N	f	published	23	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9435d633-81f3-49bd-8fcd-e793b3df1b6a	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Housing Studies	housing-studies	\N	f	published	24	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ab161721-8dd6-48be-89c5-819b4ed65ee1	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Facilities Management	facilities-management	\N	f	published	25	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
72754add-ce37-47b5-a278-209b57ffb335	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Property Development	property-development	\N	f	published	26	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b87e8bf5-42d5-42aa-917b-37148fd64991	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Planning & Development	planning-development	\N	f	published	27	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6a1cc6f6-c9ea-4122-a38c-a40da3aa1d9d	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Heritage Conservation	heritage-conservation	\N	f	published	28	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5df1b08d-4e56-4540-9e53-0b2431d6244f	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Architectural Conservation	architectural-conservation	\N	f	published	29	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
72000abd-87cb-4c79-a8c6-bfc8bc539020	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Urban Development	urban-development	\N	f	published	30	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4089bcc9-dbb4-417e-ae9e-521e2dd5eb9d	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Environmental Design	environmental-design	\N	f	published	31	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
28d9acad-ddf5-41b4-b64c-b93b6ca5eae8	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Construction Technology	construction-technology	\N	f	published	32	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
99c634f2-f660-410e-b11f-5950dc6ffea5	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Humanities	humanities	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1975afe0-3347-49a7-9e94-92232d27ae95	969d467c-ab12-44d9-ba02-dd9cf1726d5e	History	history	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b9293492-b3fa-42e9-b003-8884af7c42bb	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Archaeology	archaeology	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3abdffb3-d297-4e16-abd1-a622f388542d	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Ancient History	ancient-history	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
10454f62-0c35-4c08-b753-20fc5e65671a	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Classical Studies	classical-studies	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
31a05302-98c6-4de4-889d-fedc75a368ea	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Philosophy	philosophy	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e8692540-909b-4bd1-a274-88fc485ec7d8	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Ethics	ethics	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
329ed5a3-4eb5-4d08-b574-2207780af95e	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Theology	theology	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7c57758a-c141-4581-9b78-d82f0181ed26	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Religious Studies	religious-studies	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9856baf3-d34b-4dde-b73c-3cea3e292068	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Cultural Studies	cultural-studies	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
197f573b-f904-4e32-9890-1ea69f2d7f7e	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Heritage Studies	heritage-studies	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b8217988-1fa7-422e-82f8-c75eddffda95	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Museum Studies	museum-studies	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
99470eb6-5a03-47ef-bbc0-e2549d066c26	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Liberal Arts	liberal-arts	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f3809ed3-6282-48c1-a324-8eccd3a244b4	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Area Studies	area-studies	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ab11d853-a501-4f8b-8307-24899b3357c9	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Gender Studies	gender-studies	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9e72b652-d8fd-4eaf-801e-6a148757ac32	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Women's Studies	womens-studies	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c8b25729-be18-40e9-9fae-82c354263580	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Languages & Literature	languages-literature	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cade6721-ba9f-4a72-a9fb-b4ec553d1934	969d467c-ab12-44d9-ba02-dd9cf1726d5e	English	english	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8337283e-d37b-44f5-a0d1-ca954ba2d221	969d467c-ab12-44d9-ba02-dd9cf1726d5e	English Literature	english-literature	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d53b6252-a590-4a7a-9b2b-29c0a94d388c	969d467c-ab12-44d9-ba02-dd9cf1726d5e	English Studies	english-studies	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ca7ba145-7551-47d7-a772-f5c443d982d5	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Comparative Literature	comparative-literature	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
61c2204b-4245-4299-a103-7fbd0c790384	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Linguistics	linguistics	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
66102fac-3f88-4a28-9faf-010c8e6739a5	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Applied Linguistics	applied-linguistics-arts-humanities-social-sciences	\N	f	published	23	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a047aadc-9d3c-4035-a139-a76d5968042a	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Translation	translation	\N	f	published	24	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3a9a1d16-6da9-49c7-8d00-66ba71aea1aa	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Interpretation	interpretation	\N	f	published	25	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b6cbb065-9bec-4eae-94cc-48372f7cd4c7	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Modern Languages	modern-languages	\N	f	published	26	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
bf86b2b1-7a98-4586-8084-bef8467256ac	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Foreign Languages	foreign-languages	\N	f	published	27	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2d820272-d59d-49e3-9b01-b72c6bd71fe9	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Creative Writing	creative-writing	\N	f	published	28	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f46923fd-d6aa-41e1-9fdc-2344391aab7d	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Literature	literature	\N	f	published	29	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
54bacfd4-69f0-495a-a197-ef146dab84e8	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Classical Languages	classical-languages	\N	f	published	30	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0c6812ad-1ce5-46d9-9ffb-093fae0456bb	969d467c-ab12-44d9-ba02-dd9cf1726d5e	French	french	\N	f	published	31	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e6fc0109-3a64-43cb-ab0c-56aa4cace896	969d467c-ab12-44d9-ba02-dd9cf1726d5e	German	german	\N	f	published	32	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3e1f46a4-09a8-4d3c-9f0f-2906e5bea6ab	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Spanish	spanish	\N	f	published	33	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4cc9490a-8e29-45de-b3aa-0ef9e515fe5a	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Italian	italian	\N	f	published	34	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ff3c1f59-1520-4c8e-adbd-0804c3f81bf1	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Japanese	japanese	\N	f	published	35	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f081b26b-247f-4d3a-8f23-0180efe2e36d	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Chinese	chinese	\N	f	published	36	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
32340251-1fa4-4d99-a5b1-fe7cfe229fa4	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Arabic	arabic	\N	f	published	37	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ccab84c6-ef44-4866-a9c6-840abc283bca	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Korean	korean	\N	f	published	38	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5dcd8014-44d7-403e-b793-05e442c699b8	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Social Sciences	social-sciences	\N	f	published	39	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c03c2153-ee49-4a5e-83dd-bd1baee81dfa	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Sociology	sociology	\N	f	published	40	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fa3c9c50-e034-4966-b97f-173fd1227d8f	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Psychology	psychology-arts-humanities-social-sciences	\N	f	published	41	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
530b9a05-edc2-4e17-9511-b7c71296c98c	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Social Work	social-work-arts-humanities-social-sciences	\N	f	published	42	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
aa292120-725d-44a9-b7f5-0be1af528a5d	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Anthropology	anthropology	\N	f	published	43	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
95a934e5-bd0f-4c94-95e2-91f0a5a813a3	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Criminology	criminology-arts-humanities-social-sciences	\N	f	published	44	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
76da13b6-9a30-4f80-90f8-bc09ab018535	969d467c-ab12-44d9-ba02-dd9cf1726d5e	International Relations	international-relations-arts-humanities-social-sciences	\N	f	published	45	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
75f0baef-31fb-4f1c-a6ff-d7f9c8967e47	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Political Science	political-science-arts-humanities-social-sciences	\N	f	published	46	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a4264bc8-2597-46ad-b286-7b2defb3ae5d	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Politics	politics-arts-humanities-social-sciences	\N	f	published	47	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6c53bd78-89d3-436b-98be-b467a87b7af5	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Public Policy	public-policy-arts-humanities-social-sciences	\N	f	published	48	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
25b8a204-1e8d-4685-804b-dc9fc203cf17	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Development Studies	development-studies-arts-humanities-social-sciences	\N	f	published	49	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e3370c4e-0c0a-453a-a4c5-fdc3cadac1ed	969d467c-ab12-44d9-ba02-dd9cf1726d5e	International Development	international-development-arts-humanities-social-sciences	\N	f	published	50	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
68bc354d-47c2-4699-b27d-4fd81c9fefd9	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Economics	economics-arts-humanities-social-sciences	\N	f	published	51	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1014c872-466b-4d50-92d8-7fc20c3ea07a	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Geography	geography	\N	f	published	52	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
45c47b1c-c4cb-4e52-93e9-90c247946d56	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Human Geography	human-geography	\N	f	published	53	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
38d689d7-e50e-42a0-8859-de148542aad3	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Social Policy	social-policy-arts-humanities-social-sciences	\N	f	published	54	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3b8f9bcf-b881-4c09-901e-463b52c500cb	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Social Research	social-research	\N	f	published	55	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cf90cb2a-6293-4d41-9a16-f44e4e9cb761	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Community Development	community-development-arts-humanities-social-sciences	\N	f	published	56	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
65db8c89-c259-4480-9370-f18f2a1716fa	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Migration Studies	migration-studies-arts-humanities-social-sciences	\N	f	published	57	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b97267a6-777a-4406-9f19-ee6875425e9a	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Peace & Conflict Studies	peace-conflict-studies	\N	f	published	58	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b7693cb4-847f-4499-b170-9470133a7a4c	969d467c-ab12-44d9-ba02-dd9cf1726d5e	Security Studies	security-studies-arts-humanities-social-sciences	\N	f	published	59	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
43f48c66-7308-41d9-b01b-788d4b29d32b	969d467c-ab12-44d9-ba02-dd9cf1726d5e	International Studies	international-studies-arts-humanities-social-sciences	\N	f	published	60	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d97d749c-4eb9-4b01-9c1f-58a7ddc617de	6217a93d-16b1-48b1-9206-4b3589dcd87b	Accounting	accounting-business-management	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
bd756593-6c6b-452b-ae3b-684f7758e73e	6217a93d-16b1-48b1-9206-4b3589dcd87b	Accounting & Finance	accounting-finance-business-management	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8adfc50b-9304-488f-a603-c326a696e04a	6217a93d-16b1-48b1-9206-4b3589dcd87b	Auditing	auditing-business-management	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
60fc820b-f2d4-4f19-869b-02443a09b05b	6217a93d-16b1-48b1-9206-4b3589dcd87b	Taxation	taxation-business-management	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4448d597-2974-468c-83b4-53f0f8a5df5c	6217a93d-16b1-48b1-9206-4b3589dcd87b	Banking	banking-business-management	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d508ea90-0ee9-40ef-8dcf-b3c056f8cb99	6217a93d-16b1-48b1-9206-4b3589dcd87b	Finance	finance-business-management	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0626be18-cabf-4860-887c-495c113b1a5e	6217a93d-16b1-48b1-9206-4b3589dcd87b	Financial Management	financial-management-business-management	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8ebf569f-9715-49cc-8552-6155cd8bc596	6217a93d-16b1-48b1-9206-4b3589dcd87b	Financial Technology	financial-technology-business-management	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
dbaf6860-3b14-4a8f-8d35-39c50eb4162e	6217a93d-16b1-48b1-9206-4b3589dcd87b	Investment Management	investment-management-business-management	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a9bc4cd6-8cad-4329-af56-7c0b186ea0ab	6217a93d-16b1-48b1-9206-4b3589dcd87b	Economics	economics-business-management	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
48ce863b-3dc3-4ef9-8048-994d108d911c	6217a93d-16b1-48b1-9206-4b3589dcd87b	Business Economics	business-economics	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d64d2812-9ffd-42fa-98ce-129287509eee	6217a93d-16b1-48b1-9206-4b3589dcd87b	Business Administration	business-administration	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
79a3797d-e7d5-425e-9551-5d7d58dc7a71	6217a93d-16b1-48b1-9206-4b3589dcd87b	Business Management	business-management	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8dac83be-5764-4f8e-a89e-f2a7e4b0c59b	6217a93d-16b1-48b1-9206-4b3589dcd87b	International Business	international-business	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2b8f354d-725f-462d-b944-8996a345f492	6217a93d-16b1-48b1-9206-4b3589dcd87b	Global Business	global-business	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
539897d9-2092-4252-ae9e-f40a62d9730b	6217a93d-16b1-48b1-9206-4b3589dcd87b	Business Analytics	business-analytics-business-management	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5eff4590-c669-4451-baff-bd87cbfb89a0	6217a93d-16b1-48b1-9206-4b3589dcd87b	Business Intelligence	business-intelligence	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
709c8f7e-f224-4924-903c-fe0da0209d13	6217a93d-16b1-48b1-9206-4b3589dcd87b	Business Strategy	business-strategy	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
13ebc3b7-dee9-4953-8494-956091b8ef5d	6217a93d-16b1-48b1-9206-4b3589dcd87b	Entrepreneurship	entrepreneurship	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cb270fbe-c83c-4043-be80-2207c8433a7a	6217a93d-16b1-48b1-9206-4b3589dcd87b	Innovation Management	innovation-management	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
980a0c79-e51d-425d-bf50-d0ea0ef75f78	6217a93d-16b1-48b1-9206-4b3589dcd87b	Marketing	marketing	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5cf6cc4e-e62c-46f3-ad55-cfd1f40cade4	6217a93d-16b1-48b1-9206-4b3589dcd87b	Digital Marketing	digital-marketing	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
bfcbf0a2-7ae3-48fb-b230-8631f4abe06b	6217a93d-16b1-48b1-9206-4b3589dcd87b	International Marketing	international-marketing	\N	f	published	23	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
80bac62d-89cf-48a4-b5e7-ba796d1fdd35	6217a93d-16b1-48b1-9206-4b3589dcd87b	Advertising	advertising-business-management	\N	f	published	24	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4e145282-b6da-4e2f-9921-1bb218c4c8c4	6217a93d-16b1-48b1-9206-4b3589dcd87b	Brand Management	brand-management	\N	f	published	25	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
faf857be-99c9-4a1e-a88b-fd013d22ea88	6217a93d-16b1-48b1-9206-4b3589dcd87b	Sales Management	sales-management	\N	f	published	26	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
317f7145-72eb-4824-aa8f-bb1beab3ff56	6217a93d-16b1-48b1-9206-4b3589dcd87b	Retail Management	retail-management	\N	f	published	27	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
def5393e-0f9f-4360-a2a6-379fb6dc5a92	6217a93d-16b1-48b1-9206-4b3589dcd87b	Human Resource Management	human-resource-management	\N	f	published	28	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
726a68f2-9ad3-46d9-8511-dce6bcecf26d	6217a93d-16b1-48b1-9206-4b3589dcd87b	Human Resources	human-resources	\N	f	published	29	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ae8906f4-0a95-4075-853d-d5a6d670040c	6217a93d-16b1-48b1-9206-4b3589dcd87b	Organisational Behaviour	organisational-behaviour	\N	f	published	30	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
bf19f218-8d6f-4e59-9a5f-f7b6a777d8e2	6217a93d-16b1-48b1-9206-4b3589dcd87b	Leadership	leadership	\N	f	published	31	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2b9fe344-b1e3-4e87-ad66-3b0878e5e7e6	6217a93d-16b1-48b1-9206-4b3589dcd87b	Management	management	\N	f	published	32	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
77357f6f-937d-4edf-aa1a-57fc14987d4c	6217a93d-16b1-48b1-9206-4b3589dcd87b	Operations Management	operations-management-business-management	\N	f	published	33	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
93c3edc5-0785-437d-89f9-fdfa54c510a3	6217a93d-16b1-48b1-9206-4b3589dcd87b	Project Management	project-management	\N	f	published	34	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
90ea2d8e-8cd6-4aa1-9c20-a03aedba1dca	6217a93d-16b1-48b1-9206-4b3589dcd87b	Supply Chain Management	supply-chain-management-business-management	\N	f	published	35	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e69d0219-c2d6-4039-8d30-66defc2f1957	6217a93d-16b1-48b1-9206-4b3589dcd87b	Logistics	logistics-business-management	\N	f	published	36	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
43752fb6-4d47-491d-8fc6-3c7a95c3916d	6217a93d-16b1-48b1-9206-4b3589dcd87b	Procurement	procurement-business-management	\N	f	published	37	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
702a0c12-de66-4e3b-9d5f-12960f96f4cc	6217a93d-16b1-48b1-9206-4b3589dcd87b	Information Management	information-management	\N	f	published	38	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
add02b07-1c89-4cfa-aa27-0ccfdb5d7869	6217a93d-16b1-48b1-9206-4b3589dcd87b	Risk Management	risk-management-business-management	\N	f	published	39	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
84f72368-1a20-424c-bb05-725983ae29c9	6217a93d-16b1-48b1-9206-4b3589dcd87b	Insurance	insurance-business-management	\N	f	published	40	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
698b4b44-fb9a-4e0b-a551-712af7697cdd	6217a93d-16b1-48b1-9206-4b3589dcd87b	Actuarial Science	actuarial-science-business-management	\N	f	published	41	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4beba3fb-9adc-4747-88f6-398864eed39b	6217a93d-16b1-48b1-9206-4b3589dcd87b	Hospitality Management	hospitality-management-business-management	\N	f	published	42	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cdcc0202-569e-47d2-aeb5-e4f63b841c89	6217a93d-16b1-48b1-9206-4b3589dcd87b	Tourism Management	tourism-management-business-management	\N	f	published	43	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8c8dfe3c-3d44-44df-829f-ab23519c190d	6217a93d-16b1-48b1-9206-4b3589dcd87b	Event Management	event-management-business-management	\N	f	published	44	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
19d93a00-7076-4b2e-900d-e41d12b04812	6217a93d-16b1-48b1-9206-4b3589dcd87b	Sports Management	sports-management-business-management	\N	f	published	45	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
faf2af87-039b-4248-812d-1496a1946b0f	6217a93d-16b1-48b1-9206-4b3589dcd87b	Luxury Management	luxury-management	\N	f	published	46	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b480b89c-c6f1-4561-b349-a7ce36fa2a33	6217a93d-16b1-48b1-9206-4b3589dcd87b	Fashion Management	fashion-management-business-management	\N	f	published	47	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7ad14335-3dc1-48e9-9f0d-cb68bbf594f4	6217a93d-16b1-48b1-9206-4b3589dcd87b	Healthcare Management	healthcare-management-business-management	\N	f	published	48	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3ab8fd57-b4c3-48eb-a5cd-78fef0110678	6217a93d-16b1-48b1-9206-4b3589dcd87b	Construction Management	construction-management-business-management	\N	f	published	49	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
52a88794-b6a1-4f2c-a00c-7b390fa906f4	6217a93d-16b1-48b1-9206-4b3589dcd87b	International Management	international-management	\N	f	published	50	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9a3a2a56-918a-48c5-a5e5-0a2be1d54d81	6217a93d-16b1-48b1-9206-4b3589dcd87b	Strategic Management	strategic-management	\N	f	published	51	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c3ca35a5-14f0-4ead-858f-139332088cc6	6217a93d-16b1-48b1-9206-4b3589dcd87b	Corporate Governance	corporate-governance	\N	f	published	52	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2d004b38-3189-42a1-a72c-a1935b780dea	6217a93d-16b1-48b1-9206-4b3589dcd87b	Business Law	business-law-business-management	\N	f	published	53	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
057f9f6e-5279-45bf-9117-1381179f75d0	6217a93d-16b1-48b1-9206-4b3589dcd87b	Commercial Management	commercial-management	\N	f	published	54	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4bed078d-8032-4623-bd32-68a69471f57a	6217a93d-16b1-48b1-9206-4b3589dcd87b	Public Administration	public-administration-business-management	\N	f	published	55	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ec69b0ab-450c-4c3e-8cad-59cb011bbac1	6217a93d-16b1-48b1-9206-4b3589dcd87b	Management Consulting	management-consulting	\N	f	published	56	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f2e2bd1f-ecb9-42f8-a20e-a021235801c6	6217a93d-16b1-48b1-9206-4b3589dcd87b	FinTech	fintech-business-management	\N	f	published	57	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d5cd0b80-f3de-4936-9158-7c88f4f99f7d	6217a93d-16b1-48b1-9206-4b3589dcd87b	Real Estate Management	real-estate-management-business-management	\N	f	published	58	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
eb26903a-93bd-4250-b420-0ced0d06f52e	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Computer Science	computer-science	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
61763902-b1a9-4466-841e-4ee6bfd33a0a	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Information Technology	information-technology	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3fad4972-91a2-4ba2-a8b1-a2f0998cfffb	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Information Systems	information-systems	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
371e795d-d671-4353-b584-c7561247a898	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Software Engineering	software-engineering-computing-information-technology	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
074ce1c5-9992-4306-8fcd-3b975a336246	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Computer Engineering	computer-engineering-computing-information-technology	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
da17d3c2-c205-45c4-96e1-d4bd202cdcf8	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Computer Programming	computer-programming	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d3f43788-451c-497c-a56d-42651768a86c	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Web Development	web-development	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fe1f07ed-3fc0-4b79-95d2-a2a977feb636	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Web Design	web-design	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
51392928-2f52-4b21-a31c-e39678313c70	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Mobile Application Development	mobile-application-development	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cd01ce84-a259-4eda-b513-06e9ee49980c	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Internet Application Development	internet-application-development	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
56d74358-6627-4c0d-b4df-02e091af8ace	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Cloud Computing	cloud-computing	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a4c7a157-bb0f-4883-8a82-5272d385b13c	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Cloud Engineering	cloud-engineering	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5d3d971a-4d07-40f1-956c-220fb58a02e6	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Cyber Security	cyber-security-computing-information-technology	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
eef405fc-fb47-4f9b-a607-a29eb80c3461	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Information Security	information-security-computing-information-technology	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ff25d28a-bd0e-4b98-9d20-d0d8dc653c85	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Network Security	network-security	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9108f744-bdec-46b6-99b3-1b43cf24729d	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Computer Networks	computer-networks	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
49973ad7-09fd-4f63-a8bd-59e52645efe2	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Ethical Hacking	ethical-hacking	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b61bf79e-e7ff-4a2f-b4a3-3e87a0871efa	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Digital Forensics	digital-forensics	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
34b8a36f-5295-4d5e-b186-5054ed2ab9c0	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Computer Forensics	computer-forensics	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cbfb07a9-799c-4328-b9b8-4a387f412a21	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Artificial Intelligence	artificial-intelligence-computing-information-technology	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cd3595a2-40de-4f47-84c8-15546022394c	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Machine Learning	machine-learning-computing-information-technology	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3043612b-dc8f-4043-90ff-ef8099356d8f	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Deep Learning	deep-learning	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c6b4d9e5-beb0-4249-8683-a0a25fbd8970	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Data Science	data-science-computing-information-technology	\N	f	published	23	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c34a4129-081e-448d-968f-db3ac873e2c0	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Data Analytics	data-analytics-computing-information-technology	\N	f	published	24	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a63895fd-dce3-49f1-aade-816e773dbbaa	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Big Data Analytics	big-data-analytics	\N	f	published	25	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6d8d5c14-3225-4042-916b-5cce7628237b	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Business Analytics	business-analytics-computing-information-technology	\N	f	published	26	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8a304f56-9859-41af-b8ac-05882cd59c4b	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Data Engineering	data-engineering	\N	f	published	27	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
dbc31cf4-eb3d-46da-b495-e76f8554f615	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Database Management	database-management	\N	f	published	28	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9a9810fd-0ea2-4629-a243-93616a5cfb0d	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Database Administration	database-administration	\N	f	published	29	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d6262eda-c52c-4ed8-b794-1291e86298fe	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Statistics & Data Science	statistics-data-science	\N	f	published	30	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
efc4c13f-01a1-4d13-bc77-57f524ee5188	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Robotics	robotics-computing-information-technology	\N	f	published	31	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d8e8feed-2734-434d-bcd0-31b4f2c18d68	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Autonomous Systems	autonomous-systems-computing-information-technology	\N	f	published	32	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c4142dda-2a43-4a62-8b69-38b8a3e34ef6	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Computer Vision	computer-vision	\N	f	published	33	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e9f5334b-4f4b-4565-8705-2b50f4b7ea45	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Natural Language Processing	natural-language-processing	\N	f	published	34	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
72531502-2f2e-47de-861b-41f992c37180	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Generative AI	generative-ai-computing-information-technology	\N	f	published	35	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
99a063cb-aeed-46ee-9b8e-f58b73791ad1	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Human-Computer Interaction	human-computer-interaction-computing-information-technology	\N	f	published	36	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c3a80d27-b6ee-4d35-b754-c80f56e367bc	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	User Experience Design	user-experience-design	\N	f	published	37	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
69acb632-c58d-43db-8eef-b2cb0ed1252d	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	User Interface Design	user-interface-design	\N	f	published	38	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
911ddeec-21ed-4b46-9739-0cc2ad4e26e5	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Game Development	game-development-computing-information-technology	\N	f	published	39	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9353890d-201f-4867-a149-5acfb92b2a22	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Game Design	game-design-computing-information-technology	\N	f	published	40	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
80d8582c-8ca4-4547-aec4-c0d0d934b58f	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Computer Graphics	computer-graphics	\N	f	published	41	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
12dfc4cb-7c42-40aa-aabb-f235cbc6325e	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Computer Animation	computer-animation	\N	f	published	42	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
add28972-12ee-436f-9963-42aa46d06f50	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	3D Modelling	3d-modelling	\N	f	published	43	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d3e0ca9c-b39e-4c7d-bb9b-e4d40d2828a5	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Virtual Reality	virtual-reality-computing-information-technology	\N	f	published	44	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6607e497-6ebb-4911-a17d-1be8885ddaf9	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Augmented Reality	augmented-reality-computing-information-technology	\N	f	published	45	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ab7e9e99-caea-4b58-a533-32071d780265	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Extended Reality	extended-reality-computing-information-technology	\N	f	published	46	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b33db6e1-b783-45d2-974b-965ba24137a4	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Blockchain	blockchain-computing-information-technology	\N	f	published	47	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5f25baa2-5d1e-4ce0-95e0-95ce8fc88267	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Cryptocurrency & Blockchain	cryptocurrency-blockchain	\N	f	published	48	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
328316a8-d427-4a07-8a23-2077c0505ca9	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Internet of Things	internet-of-things-computing-information-technology	\N	f	published	49	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
24628ead-add4-4ae0-86cb-f6d7ba6c1598	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	IoT	iot	\N	f	published	50	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a99a6977-411a-4e5a-b940-d223986c6444	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Embedded Systems	embedded-systems	\N	f	published	51	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
243d8a65-d1ea-44b0-9847-545c950ccfb6	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Distributed Systems	distributed-systems	\N	f	published	52	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
51babc91-9f9b-437e-b0d4-ea5d917030ce	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Software Development	software-development	\N	f	published	53	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
19495493-7d91-4800-a233-0df0b919027c	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Software Architecture	software-architecture	\N	f	published	54	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
19da2cf2-f4d2-4392-9660-d150612674de	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	DevOps	devops	\N	f	published	55	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9becd13b-6d56-4114-8bb8-0db20186009d	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	DevSecOps	devsecops	\N	f	published	56	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
53a8538b-8527-4aec-bb03-3840333f97b1	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Systems Engineering	systems-engineering-computing-information-technology	\N	f	published	57	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e14e521f-e769-467a-a9f5-b15e57fe696f	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	IT Management	it-management	\N	f	published	58	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3ca5b436-26ba-40ec-a56a-297ae8782722	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	IT Project Management	it-project-management	\N	f	published	59	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c35f3676-8df0-4b12-b3a8-37cfbc71c0f3	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Digital Transformation	digital-transformation-computing-information-technology	\N	f	published	60	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0197c585-16e6-4057-8a04-f475b9ae2650	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Health Informatics	health-informatics-computing-information-technology	\N	f	published	61	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
206b4142-6bd4-41e5-a3ac-dd40c51f53c3	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Bioinformatics	bioinformatics-computing-information-technology	\N	f	published	62	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2b93dc08-e874-4429-ab4a-91f7e9a6bd20	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Computational Science	computational-science-computing-information-technology	\N	f	published	63	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3076b862-ec03-4a94-86d1-271b702da916	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Computational Biology	computational-biology-computing-information-technology	\N	f	published	64	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
07062b68-8390-4c3d-a33b-dee005ef3ce8	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Quantum Computing	quantum-computing-computing-information-technology	\N	f	published	65	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8b65df5c-7f6f-48e9-93bc-d956c763ac17	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	FinTech	fintech-computing-information-technology	\N	f	published	66	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
85a0016c-6f16-476f-9096-75ac0c06405f	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Digital Technology	digital-technology	\N	f	published	67	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
67b662d4-9a73-41fa-986b-4bcce70498b2	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Education	education	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0fc648da-d447-44e4-8d4f-9525ce094d41	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Primary Education	primary-education	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5f4c68f6-1519-4944-9544-025fc5e7ab34	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Secondary Education	secondary-education	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
82963a7d-03ff-46f9-9a0a-6644514d1637	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Early Childhood Education	early-childhood-education	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6e7ec35f-446c-4d34-a328-5d99f5ccb2e2	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Early Years Education	early-years-education	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7d21ca12-3e01-4a32-9a1e-dbd8d7d5d8c7	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Special Education	special-education	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7046d441-7bfc-4226-97fa-f17d8f1bdce1	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Special Educational Needs	special-educational-needs	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
eeec21a4-b1fc-4455-9a11-a876e4e23afa	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Educational Psychology	educational-psychology-education-pgce-teaching	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
88bcdda8-b253-49ff-974b-2836198297cc	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Educational Leadership	educational-leadership	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d2c6b6fc-6f15-4452-8c2a-a46ac49e48e6	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Educational Management	educational-management	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
11ca8483-90d2-4240-9730-a9d8384e7784	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Educational Technology	educational-technology	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5a15b398-5cb2-4790-9f96-d106947454c3	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Teaching	teaching	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
aabe6e79-552a-4bcc-92fc-731fd7a2a78d	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Teaching Degree	teaching-degree	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
82d1db73-58c6-4817-b36a-157efb962e95	7ef86a94-d348-4493-8cdd-5d8b45e1a158	PGCE	pgce	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
18878234-7d26-47e0-a805-3a7428f5b581	7ef86a94-d348-4493-8cdd-5d8b45e1a158	PGDE	pgde	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cd1cedf2-647a-4cbf-838c-cda133c9ddee	7ef86a94-d348-4493-8cdd-5d8b45e1a158	TESOL	tesol	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f60cd8b5-4b0d-4259-bc9d-cf721738dd88	7ef86a94-d348-4493-8cdd-5d8b45e1a158	TEFL	tefl	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
499e75cf-f1fd-4e46-a5e1-54fc9eea505d	7ef86a94-d348-4493-8cdd-5d8b45e1a158	English as a Second Language	english-as-a-second-language	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a05996ef-cf44-464c-adf4-93300af38586	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Applied Linguistics	applied-linguistics-education-pgce-teaching	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
18775203-71b0-4111-a515-8b13f258cab1	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Curriculum Studies	curriculum-studies	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3b81ad57-d3bb-48f8-b206-fee1ae72e425	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Higher Education	higher-education	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
23cb1db4-4122-4dd5-b5f3-42b09744c91e	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Adult Education	adult-education	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
03d7f4c7-f6e6-4400-8d38-909ad0c67531	7ef86a94-d348-4493-8cdd-5d8b45e1a158	International Education	international-education	\N	f	published	23	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0ba834c3-323f-4c7a-991d-c0093dd14a2b	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Education Policy	education-policy	\N	f	published	24	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5e21deaa-9e4d-497d-95a2-216266a48c9d	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Childhood Studies	childhood-studies	\N	f	published	25	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d8b8fdd8-0d6c-4714-b452-b1e4b28b265d	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Child Development	child-development-education-pgce-teaching	\N	f	published	26	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a44e9b49-6312-4cb1-b40f-af10984f3674	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Counselling in Education	counselling-in-education	\N	f	published	27	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6e32a3e4-5007-4af4-ab7d-cc4b99d57084	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Sports Education	sports-education	\N	f	published	28	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ee890f16-1b38-4ac4-9c27-982a65b49a48	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Mathematics Education	mathematics-education	\N	f	published	29	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ff68ba76-0a0a-4e35-86f4-3247bd37f470	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Science Education	science-education	\N	f	published	30	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7f06d58c-e1cc-4b30-9f32-a4d00eb57d0d	7ef86a94-d348-4493-8cdd-5d8b45e1a158	English Education	english-education	\N	f	published	31	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
075528a6-13b9-445f-9f09-57f314b8649d	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Language Education	language-education	\N	f	published	32	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
94257817-a1f1-402f-aaf9-653cab9d3c81	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Music Education	music-education	\N	f	published	33	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1de258bb-c313-45ca-981a-9e09ba235a46	7ef86a94-d348-4493-8cdd-5d8b45e1a158	Art Education	art-education	\N	f	published	34	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4388422d-04e5-4d3c-aec5-2fe06efe0a56	2fade289-afaf-4576-a339-973446b73868	Mechanical Engineering	mechanical-engineering	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f9a5d560-d763-4459-bd36-5a1708a847a2	2fade289-afaf-4576-a339-973446b73868	Civil Engineering	civil-engineering	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7f6ebe65-8595-40bb-8205-a257b80ff342	2fade289-afaf-4576-a339-973446b73868	Electrical Engineering	electrical-engineering	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d13438b2-0fe2-447b-b1f9-be74eb6f5923	2fade289-afaf-4576-a339-973446b73868	Electronic Engineering	electronic-engineering	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
40d40230-8e22-4cae-a596-795ef772421f	2fade289-afaf-4576-a339-973446b73868	Electronics & Communication Engineering	electronics-communication-engineering	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b144f62d-4e04-4788-bbde-4f746a22c464	2fade289-afaf-4576-a339-973446b73868	Chemical Engineering	chemical-engineering	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
08271f36-0554-465c-aa5e-dbcff7c1ebef	2fade289-afaf-4576-a339-973446b73868	Computer Engineering	computer-engineering-engineering	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b52547cb-d917-4ddb-90e3-d5e82317b4c7	2fade289-afaf-4576-a339-973446b73868	Automotive Engineering	automotive-engineering	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
81a7588a-e661-494e-815c-21148043379b	2fade289-afaf-4576-a339-973446b73868	Aerospace Engineering	aerospace-engineering-engineering	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f7160b35-f193-40c9-a5a7-65632c17a4b8	2fade289-afaf-4576-a339-973446b73868	Aeronautical Engineering	aeronautical-engineering-engineering	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a74be4fb-b01e-4090-8955-2035a1959d35	2fade289-afaf-4576-a339-973446b73868	Biomedical Engineering	biomedical-engineering-engineering	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
611fa0b1-2326-470d-a966-2a333e7579b2	2fade289-afaf-4576-a339-973446b73868	Biotechnology Engineering	biotechnology-engineering	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
016b9585-50bf-4370-bdff-9f8fadfeb6e2	2fade289-afaf-4576-a339-973446b73868	Environmental Engineering	environmental-engineering-engineering	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fc51742f-022a-4b5e-9f18-4de6d228fa4c	2fade289-afaf-4576-a339-973446b73868	Industrial Engineering	industrial-engineering	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
df97ac36-55a5-4b2e-a7c1-df61587d2c99	2fade289-afaf-4576-a339-973446b73868	Manufacturing Engineering	manufacturing-engineering	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
027b2abe-b6ee-43c9-9b50-a59c1d957d2f	2fade289-afaf-4576-a339-973446b73868	Production Engineering	production-engineering	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
552c8922-c5c1-4a32-b085-05e4225bfdce	2fade289-afaf-4576-a339-973446b73868	Mechatronics	mechatronics	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
137b7500-a2b2-45b4-a8c6-92fba8127b4f	2fade289-afaf-4576-a339-973446b73868	Robotics Engineering	robotics-engineering	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1f815676-4a01-458e-ad92-1854fee62952	2fade289-afaf-4576-a339-973446b73868	Structural Engineering	structural-engineering	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c7e54f5e-b0cd-4a9c-b175-243e0c8b8ab4	2fade289-afaf-4576-a339-973446b73868	Transportation Engineering	transportation-engineering	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
97902727-5cf0-439e-8eb3-428445e8a5e1	2fade289-afaf-4576-a339-973446b73868	Railway Engineering	railway-engineering	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
907be4fe-142f-426e-9983-0b364cdafff8	2fade289-afaf-4576-a339-973446b73868	Marine Engineering	marine-engineering-engineering	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4317ec1e-3eef-4bde-9abd-fa5d64fa64eb	2fade289-afaf-4576-a339-973446b73868	Naval Architecture	naval-architecture-engineering	\N	f	published	23	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
30debd00-fb34-4992-8e6b-7f7f294c336a	2fade289-afaf-4576-a339-973446b73868	Petroleum Engineering	petroleum-engineering-engineering	\N	f	published	24	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4ae02cec-c249-4cf7-beee-4a66872ece12	2fade289-afaf-4576-a339-973446b73868	Oil & Gas Engineering	oil-gas-engineering-engineering	\N	f	published	25	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5947e1ce-3f86-4c88-ab27-4dedf75a884a	2fade289-afaf-4576-a339-973446b73868	Mining Engineering	mining-engineering-engineering	\N	f	published	26	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ec7fb3d1-c978-4865-afb0-c5aff1651b90	2fade289-afaf-4576-a339-973446b73868	Materials Engineering	materials-engineering	\N	f	published	27	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
972810f4-d60f-43f1-a349-0d60a968302b	2fade289-afaf-4576-a339-973446b73868	Metallurgical Engineering	metallurgical-engineering	\N	f	published	28	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5c777596-4dd5-4aad-9473-059a193c7122	2fade289-afaf-4576-a339-973446b73868	Nuclear Engineering	nuclear-engineering	\N	f	published	29	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
54150423-e630-4100-99b8-095b9f34902c	2fade289-afaf-4576-a339-973446b73868	Energy Engineering	energy-engineering-engineering	\N	f	published	30	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c557a585-f8c3-479c-bd87-4a0e40cb8789	2fade289-afaf-4576-a339-973446b73868	Renewable Energy Engineering	renewable-energy-engineering	\N	f	published	31	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fb46df5a-6262-4a49-a02f-51733adea21a	2fade289-afaf-4576-a339-973446b73868	Power Engineering	power-engineering	\N	f	published	32	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c52f4a4d-9131-460e-a7f2-381d98401cf1	2fade289-afaf-4576-a339-973446b73868	Telecommunications Engineering	telecommunications-engineering	\N	f	published	33	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cb2cb7df-25c5-4555-97a5-a3cef3fc58c1	2fade289-afaf-4576-a339-973446b73868	Systems Engineering	systems-engineering-engineering	\N	f	published	34	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4bcdeabf-00e0-4e59-8bb5-6563971ae839	2fade289-afaf-4576-a339-973446b73868	Software Engineering	software-engineering-engineering	\N	f	published	35	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b7ca1924-e300-444e-a88d-f01bddf36687	2fade289-afaf-4576-a339-973446b73868	Artificial Intelligence Engineering	artificial-intelligence-engineering	\N	f	published	36	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b3bf181f-f10c-467e-ad0e-ccfcf5773108	2fade289-afaf-4576-a339-973446b73868	Automation Engineering	automation-engineering	\N	f	published	37	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
73605921-7a7c-476f-abf4-d8927dfb354e	2fade289-afaf-4576-a339-973446b73868	Control Engineering	control-engineering	\N	f	published	38	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
297fcfb2-3e7b-4f38-b8e9-65dc5e0de5d9	2fade289-afaf-4576-a339-973446b73868	Instrumentation Engineering	instrumentation-engineering	\N	f	published	39	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
032d35b4-43c4-4b0f-a88f-6f60f4bfc0f1	2fade289-afaf-4576-a339-973446b73868	Engineering Management	engineering-management	\N	f	published	40	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b095fd88-d62a-454a-845f-60407ee67b25	2fade289-afaf-4576-a339-973446b73868	Engineering Design	engineering-design	\N	f	published	41	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8ea6265e-5249-46d2-8789-5bcd6c7ebb37	2fade289-afaf-4576-a339-973446b73868	Fire Safety Engineering	fire-safety-engineering	\N	f	published	42	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
34da7524-77c6-4fc7-a13a-c7c83aedebf5	2fade289-afaf-4576-a339-973446b73868	Food Engineering	food-engineering	\N	f	published	43	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
dd060f79-2563-4aab-9195-d7543c27580f	2fade289-afaf-4576-a339-973446b73868	Agricultural Engineering	agricultural-engineering-engineering	\N	f	published	44	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5df49bd3-d0ec-4a4f-9a66-7a5528bd093c	2fade289-afaf-4576-a339-973446b73868	Architectural Engineering	architectural-engineering	\N	f	published	45	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
55304091-bb90-4dbe-9d4e-00c18ce7843a	80c9db7a-2c88-41a8-b848-5499ed9cf439	Physics	physics	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5bcdb6f0-fc02-4beb-ba03-9a89ad6f1275	80c9db7a-2c88-41a8-b848-5499ed9cf439	Applied Physics	applied-physics	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
abafc484-6c8d-457d-904a-f4b751de4341	80c9db7a-2c88-41a8-b848-5499ed9cf439	Mathematics	mathematics-science	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7d3ba33e-e029-4a53-8bac-9cf1e9bceb0e	80c9db7a-2c88-41a8-b848-5499ed9cf439	Applied Mathematics	applied-mathematics-science	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
eaaf3343-e054-497c-bfc4-22d2f32ac8b2	80c9db7a-2c88-41a8-b848-5499ed9cf439	Statistics	statistics-science	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
eae88435-99c3-4c1b-a7a8-dcb2535bb04d	80c9db7a-2c88-41a8-b848-5499ed9cf439	Chemistry	chemistry	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b9cd441e-8971-43b7-8dcc-d84885727e04	80c9db7a-2c88-41a8-b848-5499ed9cf439	Applied Chemistry	applied-chemistry	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c8a8480f-5a63-4cf0-919d-367f77928f3f	80c9db7a-2c88-41a8-b848-5499ed9cf439	Biology	biology-science	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
653191d0-c31b-4b9c-abff-cea490dbe04c	80c9db7a-2c88-41a8-b848-5499ed9cf439	Biochemistry	biochemistry-science	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
66f96f98-0fc6-4a2f-8f05-8e92c7f96b71	80c9db7a-2c88-41a8-b848-5499ed9cf439	Biotechnology	biotechnology-science	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
609901f8-edf5-4c0b-9f66-d208a707998c	80c9db7a-2c88-41a8-b848-5499ed9cf439	Microbiology	microbiology-science	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
164e4d06-24fb-485c-8f55-17bd99eadac4	80c9db7a-2c88-41a8-b848-5499ed9cf439	Molecular Biology	molecular-biology-science	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0722303e-4b2c-4677-ab6d-b1ec6d4b29a8	80c9db7a-2c88-41a8-b848-5499ed9cf439	Molecular Microbiology	molecular-microbiology-science	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
eb44dcb6-bd51-4899-83ee-fdbdc2961e11	80c9db7a-2c88-41a8-b848-5499ed9cf439	Genetics	genetics-science	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6db5c053-0659-499d-8167-0cdc9207f699	80c9db7a-2c88-41a8-b848-5499ed9cf439	Genetics & Genomics	genetics-genomics	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
837eeb7e-3366-4575-8fca-8f5eccf44261	80c9db7a-2c88-41a8-b848-5499ed9cf439	Cell Biology	cell-biology-science	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5274d211-d2f8-46c0-8d18-062a4d1d8ff7	80c9db7a-2c88-41a8-b848-5499ed9cf439	Molecular Cell Biology	molecular-cell-biology-science	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ff1ce55c-cf70-4254-8f73-63236caf1552	80c9db7a-2c88-41a8-b848-5499ed9cf439	Biomedical Science	biomedical-science-science	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
53c3b097-8394-4a4d-9bbd-9c98e44a60e2	80c9db7a-2c88-41a8-b848-5499ed9cf439	Biomedical Sciences	biomedical-sciences	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
da3b07d8-a461-4340-bccb-004d9d277cc1	80c9db7a-2c88-41a8-b848-5499ed9cf439	Neuroscience	neuroscience-science	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
907dff33-17bd-4d67-8d84-35c06b5426f8	80c9db7a-2c88-41a8-b848-5499ed9cf439	Molecular Medicine	molecular-medicine	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cd0cdf08-fa56-4f50-a959-216f7bb6d41d	80c9db7a-2c88-41a8-b848-5499ed9cf439	Forensic Science	forensic-science-science	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7d45b9a3-d680-4f45-853a-b61a56362249	80c9db7a-2c88-41a8-b848-5499ed9cf439	Food Science	food-science-science	\N	f	published	23	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
04b16856-1708-4203-a10d-59891a701072	80c9db7a-2c88-41a8-b848-5499ed9cf439	Pharmaceutical Science	pharmaceutical-science-science	\N	f	published	24	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3a286521-221a-458e-bdb7-d2f79d6c73bb	80c9db7a-2c88-41a8-b848-5499ed9cf439	Pharmaceutical Chemistry	pharmaceutical-chemistry-science	\N	f	published	25	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
dcad2f70-0aec-48ed-928d-b35019bb1ccf	80c9db7a-2c88-41a8-b848-5499ed9cf439	Pharmacology	pharmacology-science	\N	f	published	26	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
befb188d-0bec-4bf6-9ffd-c7e401f07142	80c9db7a-2c88-41a8-b848-5499ed9cf439	Toxicology	toxicology-science	\N	f	published	27	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e2a4bd20-963d-42e6-81b8-a11276b3c15f	80c9db7a-2c88-41a8-b848-5499ed9cf439	Materials Science	materials-science-science	\N	f	published	28	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8e70f091-dda1-450c-a773-58d1edbc7f34	80c9db7a-2c88-41a8-b848-5499ed9cf439	Nanotechnology	nanotechnology-science	\N	f	published	29	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6b92c574-b0ec-412c-b232-28a4a30ed743	80c9db7a-2c88-41a8-b848-5499ed9cf439	Nanoscience	nanoscience	\N	f	published	30	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3f717577-4e56-41fa-82fb-3ae848e2b756	80c9db7a-2c88-41a8-b848-5499ed9cf439	Earth Science	earth-science	\N	f	published	31	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d5479fb5-851c-45b5-9193-ccdceb3e8a73	80c9db7a-2c88-41a8-b848-5499ed9cf439	Geology	geology-science	\N	f	published	32	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
33ca557e-97f7-4860-b1b8-099f22a3edb9	80c9db7a-2c88-41a8-b848-5499ed9cf439	Geophysics	geophysics	\N	f	published	33	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6b050b3e-e7e8-4c2a-8869-cc1fbc64a584	80c9db7a-2c88-41a8-b848-5499ed9cf439	Astronomy	astronomy	\N	f	published	34	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
605a045f-9eda-4b59-b22d-c0079281cbe7	80c9db7a-2c88-41a8-b848-5499ed9cf439	Astrophysics	astrophysics	\N	f	published	35	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f104b1e4-8edb-4922-8735-0705a20c5ff7	80c9db7a-2c88-41a8-b848-5499ed9cf439	Marine Science	marine-science-science	\N	f	published	36	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
27ec804e-102b-4cac-8b88-d79aff9f78cb	80c9db7a-2c88-41a8-b848-5499ed9cf439	Oceanography	oceanography-science	\N	f	published	37	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
095297a6-7d6c-4cc7-9446-16bc3483181e	80c9db7a-2c88-41a8-b848-5499ed9cf439	Environmental Science	environmental-science-science	\N	f	published	38	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e0b81bab-8c39-4eb0-8d97-05686df226ba	80c9db7a-2c88-41a8-b848-5499ed9cf439	Ecology	ecology-science	\N	f	published	39	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
da8c380c-888a-41fa-9fc0-d0a6ece51f6a	80c9db7a-2c88-41a8-b848-5499ed9cf439	Zoology	zoology-science	\N	f	published	40	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0bc7663d-bac0-4ee7-8fd6-f7b1a5e07bcf	80c9db7a-2c88-41a8-b848-5499ed9cf439	Botany	botany-science	\N	f	published	41	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
bb0a21bb-2232-495d-b95e-644e54eed095	80c9db7a-2c88-41a8-b848-5499ed9cf439	Plant Science	plant-science-science	\N	f	published	42	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b3d3790b-488c-4ece-bf5c-a719e79312d2	80c9db7a-2c88-41a8-b848-5499ed9cf439	Animal Science	animal-science-science	\N	f	published	43	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0b2a2e77-9c0e-43b3-8a82-be776d2484cd	80c9db7a-2c88-41a8-b848-5499ed9cf439	Actuarial Science	actuarial-science-science	\N	f	published	44	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
28b7db65-69c3-46a1-8bd8-067109cac22b	80c9db7a-2c88-41a8-b848-5499ed9cf439	Computational Science	computational-science-science	\N	f	published	45	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9f173c17-eafb-4da4-83ce-306d1643f82b	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Design	design	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8a5ef1eb-c0b6-40f3-b562-cee335bea2ad	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Graphic Design	graphic-design	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
87e9bf0a-aa6a-4c56-841c-6fa03cd0265c	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Communication Design	communication-design	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
11268347-afb2-47ad-8054-1a72dfbfadd0	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Visual Communication	visual-communication	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a9a4f3a0-dbd2-4f3e-86ce-443431b046c4	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Interior Design	interior-design	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ee532a91-c28a-42dc-aa7f-8a2a672a1f5d	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Product Design	product-design	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ffe9006e-8553-4c52-8841-597bd3909476	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Industrial Design	industrial-design	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fb41c654-1f7c-47fa-a79a-2f8f914cde7e	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Fashion Design	fashion-design-creative-arts-design-communication	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
71ee85c9-98ef-43c3-a04b-3bcce2d3d08c	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Fashion Technology	fashion-technology-creative-arts-design-communication	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
97c49244-91a9-4b11-9bd9-80c8952e26a5	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Fashion Styling	fashion-styling-creative-arts-design-communication	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5f9f74aa-c760-4ba6-b341-b461c7bc431f	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Fashion Merchandising	fashion-merchandising-creative-arts-design-communication	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3b2636c1-2265-45ca-aa8d-b88aacefba33	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Textile Design	textile-design-creative-arts-design-communication	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
61d0f310-e1bc-412c-8451-ed8a2dee8506	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Jewellery Design	jewellery-design-creative-arts-design-communication	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a2993dfd-384a-453b-87c8-50bb26dbc022	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Furniture Design	furniture-design	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7642357e-539d-40b6-8d6f-c4a61fbebd28	cf60d367-8dda-47c9-b15c-a0e6bb456c32	UX Design	ux-design-creative-arts-design-communication	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
08292391-fd16-4c09-a4cd-e4719e943eb4	cf60d367-8dda-47c9-b15c-a0e6bb456c32	UI Design	ui-design	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6b0ecfec-d11d-4792-95af-7d6479bbb0f1	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Interaction Design	interaction-design	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
df3e30ee-e9fc-4e98-bb9a-2fcdcd5a87a9	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Service Design	service-design	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7a50ad26-ceb9-4eb6-b778-1826f4cebc40	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Experience Design	experience-design	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9a1be7a7-fb6e-4dca-9c7c-1c2613419789	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Illustration	illustration	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
45849512-4a9f-456c-be08-34890cfb0797	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Animation	animation-creative-arts-design-communication	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
70f60cd2-c671-44c1-829d-effb7a62e9c0	cf60d367-8dda-47c9-b15c-a0e6bb456c32	3D Animation	3d-animation-creative-arts-design-communication	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7c9f120a-784c-463c-a9a7-b06690d17f61	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Motion Graphics	motion-graphics-creative-arts-design-communication	\N	f	published	23	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fa64b811-c9bc-4f13-b7fb-1e534c669d67	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Game Design	game-design-creative-arts-design-communication	\N	f	published	24	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ecdcf183-438f-481a-9e3b-ee1bb88b5810	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Film & Media	film-media	\N	f	published	25	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3aec5259-7607-4eb0-83e7-172f5a0f27d1	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Film	film	\N	f	published	26	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c4c9aa95-073f-4203-b198-a14d5990167b	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Film Production	film-production-creative-arts-design-communication	\N	f	published	27	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
90fe00b1-a396-4a93-9a21-2c576be6d55d	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Film Studies	film-studies-creative-arts-design-communication	\N	f	published	28	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6eaa6162-454f-4490-ab33-0aa876836778	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Screenwriting	screenwriting-creative-arts-design-communication	\N	f	published	29	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2f3553e2-ee40-4cae-994e-1ca93c7978ca	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Television Production	television-production-creative-arts-design-communication	\N	f	published	30	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d8784769-afbd-4fde-bb16-63909fb3450d	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Television Studies	television-studies	\N	f	published	31	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fbe1244c-8841-4e0c-bb7e-0459c2dcd504	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Media Studies	media-studies-creative-arts-design-communication	\N	f	published	32	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4660aa77-2bff-455e-8f7a-0a74512d8e31	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Digital Media	digital-media-creative-arts-design-communication	\N	f	published	33	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1257a313-053f-4c6c-a1d9-4e6d5ef22f99	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Media Production	media-production-creative-arts-design-communication	\N	f	published	34	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d0831b09-6a1b-4031-ae52-cc15ee9e3fe1	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Multimedia	multimedia	\N	f	published	35	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
38e84e35-0ca5-429d-ac5d-bb3341504a68	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Photography	photography	\N	f	published	36	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ad4de6de-0284-4648-a8ae-4ea4006b91ce	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Cinematography	cinematography	\N	f	published	37	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fd1a9948-df0a-4cca-b02c-28f8318318ff	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Visual Effects	visual-effects-creative-arts-design-communication	\N	f	published	38	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e5aec223-77bc-4f41-9815-dda821147381	cf60d367-8dda-47c9-b15c-a0e6bb456c32	VFX	vfx-creative-arts-design-communication	\N	f	published	39	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5c5b7be5-cf91-4123-8415-f0ec06170a14	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Sound Design	sound-design-creative-arts-design-communication	\N	f	published	40	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3cad8abb-6ac0-4da9-86d8-dc09e2648a84	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Music Production	music-production-creative-arts-design-communication	\N	f	published	41	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
915351e8-5950-41af-9084-49019ff24c89	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Broadcasting	broadcasting-creative-arts-design-communication	\N	f	published	42	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e6253cc8-4fcc-48dc-a499-032cdfb8f0f3	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Radio	radio	\N	f	published	43	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8d71bd10-72b0-4797-9f41-ac0dd837076b	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Podcasting	podcasting	\N	f	published	44	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2eee6daa-0ebd-4c89-bf5a-7f97c8f67c31	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Performing Arts	performing-arts-creative-arts-design-communication	\N	f	published	45	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6779d009-cd15-4916-b1c3-06e4e597e389	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Acting	acting-creative-arts-design-communication	\N	f	published	46	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b8adecdd-b0e1-4736-b0e7-d8b09ed757b5	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Drama	drama	\N	f	published	47	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
595e919f-2eeb-4439-a933-ac4d7cc3a087	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Theatre	theatre-creative-arts-design-communication	\N	f	published	48	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f832d11c-3ff9-4174-97c8-f496ccde4345	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Dance	dance	\N	f	published	49	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cfae62a4-f6fa-46a9-a9f3-54ecc63310ff	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Musical Theatre	musical-theatre	\N	f	published	50	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3d3d54d5-4c3c-40c7-b8a8-d2c717fb9a53	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Music	music	\N	f	published	51	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
13798735-488f-49a4-97b6-ce9d04165b80	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Music Performance	music-performance	\N	f	published	52	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8a22246d-d6a2-45ab-b2f4-bf11724a3122	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Composition	composition	\N	f	published	53	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
831735a4-7594-48a7-b1cb-18f23c8fa9a3	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Conducting	conducting	\N	f	published	54	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f95d23fb-6a2e-45dd-ba27-aba246c7a82f	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Theatre Production	theatre-production	\N	f	published	55	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5105dc22-7c17-4a7c-abe2-9d103e4b76fc	cf60d367-8dda-47c9-b15c-a0e6bb456c32	Theatre Design	theatre-design	\N	f	published	56	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
412ff95e-5734-486a-bb61-853164b245e6	29d0e951-5d39-453f-9590-22c15d1b49d0	Journalism	journalism	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4cd2a8b3-f9e3-413b-9af4-2d0d546cbd79	29d0e951-5d39-453f-9590-22c15d1b49d0	Mass Communication	mass-communication	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8f15315d-2d23-4bcf-81fa-d08ec338c210	29d0e951-5d39-453f-9590-22c15d1b49d0	Communications	communications	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
87e4fe5a-607f-4137-abb3-d6c5de0e9a38	29d0e951-5d39-453f-9590-22c15d1b49d0	Media & Communication	media-communication	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9a1029ef-3f5b-49b8-af06-4c73e5ad0ff9	29d0e951-5d39-453f-9590-22c15d1b49d0	Digital Communication	digital-communication	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7c460fab-c726-4777-985e-7f6a96a2ad83	29d0e951-5d39-453f-9590-22c15d1b49d0	Strategic Communication	strategic-communication	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d59036a6-8f0f-4a5a-a396-e584ef5ad74c	29d0e951-5d39-453f-9590-22c15d1b49d0	Corporate Communication	corporate-communication	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
530b1214-3423-44db-b0f2-37143ac93e1f	29d0e951-5d39-453f-9590-22c15d1b49d0	Public Relations	public-relations	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2c2e1c0e-d535-4d91-a85b-1d8816fa82af	29d0e951-5d39-453f-9590-22c15d1b49d0	International Communication	international-communication	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6a8d056b-4266-45b7-ba68-4489be09ab7a	29d0e951-5d39-453f-9590-22c15d1b49d0	Advertising	advertising-communication-media-journalism	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
67d25e81-d162-4031-bfcb-50aca2af894a	29d0e951-5d39-453f-9590-22c15d1b49d0	Media Studies	media-studies-communication-media-journalism	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
894c0313-9b81-445f-afc8-67fbd4c2c40a	29d0e951-5d39-453f-9590-22c15d1b49d0	Digital Media	digital-media-communication-media-journalism	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
990d3e24-4180-4f0d-be0f-c71f17dddffa	29d0e951-5d39-453f-9590-22c15d1b49d0	Social Media	social-media	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
65732429-973a-4e27-8028-51ee3fff3807	29d0e951-5d39-453f-9590-22c15d1b49d0	Social Media Management	social-media-management	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3a78f810-50a2-4a5d-85fb-444453e810c9	29d0e951-5d39-453f-9590-22c15d1b49d0	Broadcast Journalism	broadcast-journalism	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
409c9e24-e6c7-404d-8150-cfed80235bd3	29d0e951-5d39-453f-9590-22c15d1b49d0	Sports Journalism	sports-journalism-communication-media-journalism	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e0d43ce0-7d3c-4f93-97a9-6cc100b27ca4	29d0e951-5d39-453f-9590-22c15d1b49d0	Investigative Journalism	investigative-journalism	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0d067c5c-94c2-4047-ae83-69ca0ee9ee8e	29d0e951-5d39-453f-9590-22c15d1b49d0	Publishing	publishing	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
bd34e2fa-8072-4d1c-9e2f-5b57873c80c9	29d0e951-5d39-453f-9590-22c15d1b49d0	Publishing Studies	publishing-studies	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
432bc956-89cb-4cbc-9c31-05c94f5f7ac6	29d0e951-5d39-453f-9590-22c15d1b49d0	Content Creation	content-creation	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
322e981d-6bb2-4131-b444-39ed7a48b926	03300472-f68e-431d-a79f-4ac3cf81019f	Sports Coaching	sports-coaching	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
13144a37-c8e4-458f-ad4c-e4393c12cfe6	29d0e951-5d39-453f-9590-22c15d1b49d0	Content Strategy	content-strategy	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
098aca18-8823-42cb-80fe-96e4f7211dd8	29d0e951-5d39-453f-9590-22c15d1b49d0	Film & Television	film-television	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
90ec01ff-684d-4db6-8bdd-a93c73ca8533	29d0e951-5d39-453f-9590-22c15d1b49d0	Broadcasting	broadcasting-communication-media-journalism	\N	f	published	23	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9bd5817f-eb02-4342-a86f-7c5e9f5d3b8f	29d0e951-5d39-453f-9590-22c15d1b49d0	Public Relations & Communications	public-relations-communications	\N	f	published	24	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f31f158a-9ab0-49a3-96b1-915196e68301	c819c508-8ab3-4141-bfbb-60638764d637	Medicine	medicine	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fed0afb1-f6dd-4851-8add-2001eb8af9b0	c819c508-8ab3-4141-bfbb-60638764d637	Medical Science	medical-science	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f2d268be-02d5-4ef3-a3f9-8bee53b95f38	c819c508-8ab3-4141-bfbb-60638764d637	Biomedical Science	biomedical-science-health-medicine-veterinary-studies	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7d50f81b-9d2f-43d4-95fa-53b12b0cad5d	c819c508-8ab3-4141-bfbb-60638764d637	Clinical Science	clinical-science	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c1cb41f8-cb60-46fe-b971-d237f0a35b24	c819c508-8ab3-4141-bfbb-60638764d637	Human Biology	human-biology	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8e51c078-c5a5-4073-8376-e9920cb54100	c819c508-8ab3-4141-bfbb-60638764d637	Anatomy	anatomy-health-medicine-veterinary-studies	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f86437b7-10de-40d0-933a-98c98e586539	c819c508-8ab3-4141-bfbb-60638764d637	Physiology	physiology-health-medicine-veterinary-studies	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a4d43d4e-351a-4637-9c1d-e1ff790f3f7b	c819c508-8ab3-4141-bfbb-60638764d637	Pathology	pathology	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f30d7cc8-71ff-43b5-bb20-209fd4c173be	c819c508-8ab3-4141-bfbb-60638764d637	Pharmacology	pharmacology-health-medicine-veterinary-studies	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fe0fc3ab-a872-4cd3-b7a6-ca246d551f77	c819c508-8ab3-4141-bfbb-60638764d637	Toxicology	toxicology-health-medicine-veterinary-studies	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1610e0fe-1270-4c58-b30b-8d0737c1ad92	c819c508-8ab3-4141-bfbb-60638764d637	Immunology	immunology-health-medicine-veterinary-studies	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
055f4bc2-df76-48ff-b763-6ca7dfe4168b	c819c508-8ab3-4141-bfbb-60638764d637	Genetics	genetics-health-medicine-veterinary-studies	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c3ca3a45-0ec1-400a-a09e-79f3b20ce540	c819c508-8ab3-4141-bfbb-60638764d637	Neuroscience	neuroscience-health-medicine-veterinary-studies	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
25058221-5d6b-4c25-85b4-054067b23726	c819c508-8ab3-4141-bfbb-60638764d637	Public Health	public-health	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b981f888-81d9-4af5-9638-63b498da1f81	c819c508-8ab3-4141-bfbb-60638764d637	Epidemiology	epidemiology	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c35d65de-3ef4-427e-bddc-72abdb5398f0	c819c508-8ab3-4141-bfbb-60638764d637	Global Health	global-health	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f9bf9260-448c-497c-b95d-9e79a21844b2	c819c508-8ab3-4141-bfbb-60638764d637	Health Sciences	health-sciences	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8bb351fc-b4ae-4a16-bde1-0ac9115890c0	c819c508-8ab3-4141-bfbb-60638764d637	Health Management	health-management	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d8bf1611-071a-4f91-8347-bf1e65b5d228	c819c508-8ab3-4141-bfbb-60638764d637	Healthcare Management	healthcare-management-health-medicine-veterinary-studies	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fda1dcba-66f1-4abe-b22d-84feae57b63a	c819c508-8ab3-4141-bfbb-60638764d637	Health Informatics	health-informatics-health-medicine-veterinary-studies	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c4262f1e-97aa-485b-af13-328e77ad1fc6	c819c508-8ab3-4141-bfbb-60638764d637	Medical Biotechnology	medical-biotechnology	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
153374f6-7c21-4a3a-964d-c0d3f806bd19	c819c508-8ab3-4141-bfbb-60638764d637	Nursing	nursing	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
23c0cf71-72ad-4867-b268-7b26122a5b94	c819c508-8ab3-4141-bfbb-60638764d637	Adult Nursing	adult-nursing	\N	f	published	23	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a6cfc55a-04bd-45e3-9ba8-7ce4a9e8f4a6	c819c508-8ab3-4141-bfbb-60638764d637	Children's Nursing	childrens-nursing	\N	f	published	24	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5a55f438-ec7f-426a-95a1-3124dc825e81	c819c508-8ab3-4141-bfbb-60638764d637	Mental Health Nursing	mental-health-nursing	\N	f	published	25	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cbd83fb5-d853-444f-a8d6-bcbfa41cf1a2	c819c508-8ab3-4141-bfbb-60638764d637	Learning Disability Nursing	learning-disability-nursing	\N	f	published	26	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
95251ecd-a4a1-45eb-b857-1bbb7029773b	c819c508-8ab3-4141-bfbb-60638764d637	Nursing Practice	nursing-practice	\N	f	published	27	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c084e8ee-4a72-4d19-aab2-d0f41877aba2	c819c508-8ab3-4141-bfbb-60638764d637	Advanced Nursing	advanced-nursing	\N	f	published	28	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f93418a4-69ea-4dbe-b465-ad65593c2609	c819c508-8ab3-4141-bfbb-60638764d637	Midwifery	midwifery	\N	f	published	29	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c80f1747-0ffb-4798-a5e6-7f625f478ee7	c819c508-8ab3-4141-bfbb-60638764d637	Dentistry	dentistry	\N	f	published	30	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
658fa6e3-553f-4f61-84b5-e66883732da5	c819c508-8ab3-4141-bfbb-60638764d637	Dental Surgery	dental-surgery	\N	f	published	31	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ccd95ae5-27fb-424b-9704-5a681b5148aa	c819c508-8ab3-4141-bfbb-60638764d637	Dental Hygiene	dental-hygiene	\N	f	published	32	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e98b0fa3-0d25-4a7f-86f0-96cfef3b1842	c819c508-8ab3-4141-bfbb-60638764d637	Dental Technology	dental-technology	\N	f	published	33	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8c0c8a0a-457d-4724-b28a-bdf3004b09a1	c819c508-8ab3-4141-bfbb-60638764d637	Oral Health	oral-health	\N	f	published	34	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
36a8312f-5fb9-4c06-b32e-53eadd65fe9a	c819c508-8ab3-4141-bfbb-60638764d637	Allied Health	allied-health	\N	f	published	35	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
77804fba-b17b-48e1-ace3-beb4488ec0ec	c819c508-8ab3-4141-bfbb-60638764d637	Physiotherapy	physiotherapy	\N	f	published	36	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e73932e9-7620-4686-8ad9-741334656af5	c819c508-8ab3-4141-bfbb-60638764d637	Occupational Therapy	occupational-therapy	\N	f	published	37	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
db972892-8934-4b27-9b55-a44562bb5c86	c819c508-8ab3-4141-bfbb-60638764d637	Speech & Language Therapy	speech-language-therapy	\N	f	published	38	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
64a3903c-1d26-4eae-afe5-1ae59222ede5	c819c508-8ab3-4141-bfbb-60638764d637	Radiography	radiography	\N	f	published	39	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fdd979ca-551f-4f31-b140-fd0bf7a143b7	c819c508-8ab3-4141-bfbb-60638764d637	Medical Imaging	medical-imaging	\N	f	published	40	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0c43fc02-0e29-4e85-a3c0-8a86adc74f81	c819c508-8ab3-4141-bfbb-60638764d637	Diagnostic Imaging	diagnostic-imaging	\N	f	published	41	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
786a4763-324e-4137-aaca-62dd841efe78	c819c508-8ab3-4141-bfbb-60638764d637	Medical Laboratory Science	medical-laboratory-science	\N	f	published	42	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2396f360-8a62-4b4b-b4b9-52c4418a30ae	c819c508-8ab3-4141-bfbb-60638764d637	Optometry	optometry	\N	f	published	43	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8d38db04-8a01-466c-bb76-d0446c320b5d	c819c508-8ab3-4141-bfbb-60638764d637	Audiology	audiology	\N	f	published	44	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c10f88af-3bc3-456f-a02d-4c39cce13730	c819c508-8ab3-4141-bfbb-60638764d637	Nutrition	nutrition	\N	f	published	45	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a050687e-5f85-42ab-8f9f-7d91b4fbc44d	c819c508-8ab3-4141-bfbb-60638764d637	Dietetics	dietetics	\N	f	published	46	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
eab981f3-074a-4f7a-9979-169ca600911d	c819c508-8ab3-4141-bfbb-60638764d637	Sports Therapy	sports-therapy-health-medicine-veterinary-studies	\N	f	published	47	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f01fc8ae-7d92-498a-9f87-6b3f8fc039d1	c819c508-8ab3-4141-bfbb-60638764d637	Sports Rehabilitation	sports-rehabilitation-health-medicine-veterinary-studies	\N	f	published	48	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fcc4920a-ef5b-4a9d-98b2-24c82040bcbc	c819c508-8ab3-4141-bfbb-60638764d637	Occupational Health	occupational-health	\N	f	published	49	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c27e8725-217f-41ac-98e8-e23e0c2fa6e5	c819c508-8ab3-4141-bfbb-60638764d637	Paramedic Science	paramedic-science	\N	f	published	50	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ca0ea8a9-c999-459a-b1bd-1fa59e1a3720	c819c508-8ab3-4141-bfbb-60638764d637	Veterinary	veterinary	\N	f	published	51	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fb5f2ca7-5de7-431e-af74-047fa64a694f	c819c508-8ab3-4141-bfbb-60638764d637	Veterinary Medicine	veterinary-medicine	\N	f	published	52	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
bca7ba14-32e8-418f-9a94-c2a1420deaa3	c819c508-8ab3-4141-bfbb-60638764d637	Veterinary Science	veterinary-science	\N	f	published	53	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5e4e84fa-e5b3-48b3-9f30-357f37abc6cb	c819c508-8ab3-4141-bfbb-60638764d637	Veterinary Nursing	veterinary-nursing	\N	f	published	54	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
273cff20-5f61-4349-84fd-bbf7335b9246	c819c508-8ab3-4141-bfbb-60638764d637	Animal Health	animal-health	\N	f	published	55	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
04393c65-f17a-4f56-9e23-59f7ad385bec	c819c508-8ab3-4141-bfbb-60638764d637	Animal Behaviour	animal-behaviour	\N	f	published	56	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
65179a00-ddce-42f5-a1bc-896cb2f593a4	c819c508-8ab3-4141-bfbb-60638764d637	Veterinary Bioscience	veterinary-bioscience	\N	f	published	57	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
66d128d2-6640-4102-a1d6-a985e857c602	923cc411-0a83-4ced-97a8-4485c695b3af	Law	law	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d6e337db-9fa9-442e-8352-2bab791632ef	923cc411-0a83-4ced-97a8-4485c695b3af	International Law	international-law	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a97f3430-b47c-47f1-9958-3e6b49f1d060	923cc411-0a83-4ced-97a8-4485c695b3af	Commercial Law	commercial-law	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4d9ba3e7-a4b6-4d9f-a354-f65dcce5e2a5	923cc411-0a83-4ced-97a8-4485c695b3af	Corporate Law	corporate-law	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
888173dc-aba9-4d90-8253-bb63d6422547	923cc411-0a83-4ced-97a8-4485c695b3af	Business Law	business-law-law	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6bc211ae-a32d-463c-8bf7-5aa073808481	923cc411-0a83-4ced-97a8-4485c695b3af	Criminal Law	criminal-law	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ab257fbc-3b0d-42d2-a13e-04fc5b1cc6b8	923cc411-0a83-4ced-97a8-4485c695b3af	Criminal Justice	criminal-justice-law	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6417f193-ba0d-4248-95fd-fb1e87230ecc	923cc411-0a83-4ced-97a8-4485c695b3af	Criminology	criminology-law	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7ab7cefb-ed71-4467-b602-9b362bce70d2	923cc411-0a83-4ced-97a8-4485c695b3af	Human Rights Law	human-rights-law	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5c6f71c7-46df-43eb-9331-ead1a91a126d	923cc411-0a83-4ced-97a8-4485c695b3af	European Law	european-law	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2598ea2b-cb0a-4a5f-b184-144952beaf7a	923cc411-0a83-4ced-97a8-4485c695b3af	Constitutional Law	constitutional-law	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
31c37fca-1fdd-4ae5-b97d-bbf51b49b9a9	923cc411-0a83-4ced-97a8-4485c695b3af	International Human Rights	international-human-rights	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1a084095-1fed-4951-9acf-15d2724fcd14	923cc411-0a83-4ced-97a8-4485c695b3af	Intellectual Property Law	intellectual-property-law	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4209c0f1-bec5-4f93-9c18-acde5b329556	923cc411-0a83-4ced-97a8-4485c695b3af	Technology Law	technology-law	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
013ffe73-2e4a-4228-a588-91cc548baf24	923cc411-0a83-4ced-97a8-4485c695b3af	Cyber Law	cyber-law	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8e87aa42-35d2-46c1-9248-577c31fb5656	923cc411-0a83-4ced-97a8-4485c695b3af	Environmental Law	environmental-law	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f6032889-43bb-4183-8d2d-964a6eaafcc0	923cc411-0a83-4ced-97a8-4485c695b3af	Maritime Law	maritime-law-law	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
487ab63f-533c-48db-b7d9-0c78a581d94f	923cc411-0a83-4ced-97a8-4485c695b3af	Tax Law	tax-law	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0593fdb0-13f9-47b1-b84f-fd08662e51fb	923cc411-0a83-4ced-97a8-4485c695b3af	Employment Law	employment-law	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ef590147-31ed-41d2-84dc-dd6fca2a26be	923cc411-0a83-4ced-97a8-4485c695b3af	Family Law	family-law	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9eb8b167-ca0d-4cea-8a97-3e629eac225d	923cc411-0a83-4ced-97a8-4485c695b3af	Immigration Law	immigration-law	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
35fb75fc-006c-4f5b-a3ef-0f7e863afd25	923cc411-0a83-4ced-97a8-4485c695b3af	Legal Practice	legal-practice	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
88918c74-d530-4655-969f-56ff896f34fd	923cc411-0a83-4ced-97a8-4485c695b3af	Legal Studies	legal-studies	\N	f	published	23	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1da8c324-1419-4496-acec-9270a132d54f	923cc411-0a83-4ced-97a8-4485c695b3af	Paralegal Studies	paralegal-studies	\N	f	published	24	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9f7cb82f-4fb1-4513-b054-82a170eddad5	923cc411-0a83-4ced-97a8-4485c695b3af	Arbitration	arbitration	\N	f	published	25	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4e6fc305-450c-438f-b6cd-a9c368a175c7	923cc411-0a83-4ced-97a8-4485c695b3af	Dispute Resolution	dispute-resolution	\N	f	published	26	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
514914fa-7167-4111-aa07-1c4019318eee	923cc411-0a83-4ced-97a8-4485c695b3af	International Business Law	international-business-law	\N	f	published	27	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
15c68078-10d9-4beb-98a1-3f5135205590	923cc411-0a83-4ced-97a8-4485c695b3af	Banking & Finance Law	banking-finance-law	\N	f	published	28	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0ec31097-9a9e-4619-8831-10cd852e3ef4	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Hospitality Management	hospitality-management-hospitality-tourism-events	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a51cde7f-f03f-4698-b932-6dca734c2e12	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Hotel Management	hotel-management-hospitality-tourism-events	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
549349c7-42e5-4963-aa32-cce7208e0c5d	1fc4061b-cb36-4a3f-8463-3cd114d7b659	International Hospitality	international-hospitality	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e93458e6-a3ab-48cb-a5e0-58e74e18aece	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Tourism Management	tourism-management-hospitality-tourism-events	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
18180344-83ea-4aa7-bb75-c57d453ea965	1fc4061b-cb36-4a3f-8463-3cd114d7b659	International Tourism	international-tourism	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ff93c8c8-d581-4198-9397-c556e180eab2	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Travel & Tourism	travel-tourism	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
808f870b-7a3d-4543-9ba6-f086239cddcf	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Event Management	event-management-hospitality-tourism-events	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
73b8a928-eb3d-40c4-bc48-57223eb7c99f	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Events & Entertainment	events-entertainment	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c474eccb-d81d-444c-989c-dd487d00765e	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Sports Events Management	sports-events-management	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ff334cba-1dea-496c-802c-70de1c942b22	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Hotel Administration	hotel-administration	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
93cfe7fc-6e6a-4271-956a-23c11911da38	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Restaurant Management	restaurant-management-hospitality-tourism-events	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
43dddd06-d7f4-4519-b612-302de7ce108b	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Food & Beverage Management	food-beverage-management-hospitality-tourism-events	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ffe06943-6dd7-4dad-a276-38affad6bc85	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Culinary Arts	culinary-arts-hospitality-tourism-events	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d6e8ccf7-f6c9-4405-9459-e0cb0b5ace34	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Professional Cookery	professional-cookery-hospitality-tourism-events	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
56de1e9f-6d5c-4580-9213-c24fb842efcb	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Baking & Patisserie	baking-patisserie	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
299e2de2-4ae7-4a5d-bc16-dce3a9ffb99b	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Food & Hospitality	food-hospitality	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e35e7e79-af47-447f-9444-811376ece2de	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Resort Management	resort-management-hospitality-tourism-events	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0ce87ad6-0fc2-4ab0-a9c2-822296599be5	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Leisure Management	leisure-management	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d76eb219-22a5-4915-b972-04f39a5db895	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Tourism Marketing	tourism-marketing	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9c313d70-2aaa-4cbe-8c8f-bdf6d7fa7f2c	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Sustainable Tourism	sustainable-tourism	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
dc3a15fd-d652-481a-a692-10df842d7a43	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Aviation Hospitality	aviation-hospitality	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a76ee8b2-e5a9-4e05-9ec4-dd69e906bd5e	1fc4061b-cb36-4a3f-8463-3cd114d7b659	Cruise Management	cruise-management	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
20f6b461-ccf2-4db0-989b-b18f394c1fdc	03300472-f68e-431d-a79f-4ac3cf81019f	Sports Science	sports-science	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4e6b30b1-4f4e-43ac-8df2-228bdf2f97ea	03300472-f68e-431d-a79f-4ac3cf81019f	Sport & Exercise Science	sport-exercise-science	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3547451c-6d24-477b-9182-2e9d94a48ede	03300472-f68e-431d-a79f-4ac3cf81019f	Sports Management	sports-management-sports-exercise	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ac42af0e-8b58-4c75-a8da-cacbd454fd63	03300472-f68e-431d-a79f-4ac3cf81019f	Sports Psychology	sports-psychology	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
92846acb-0c74-47de-ac70-24d1f31fc16f	03300472-f68e-431d-a79f-4ac3cf81019f	Exercise Physiology	exercise-physiology	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
006aff96-a90b-4e2e-82e0-8262c53e99b9	03300472-f68e-431d-a79f-4ac3cf81019f	Exercise Science	exercise-science	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e19ebd83-10a0-4d52-82df-df166220fd5e	03300472-f68e-431d-a79f-4ac3cf81019f	Strength & Conditioning	strength-conditioning	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3b694e2a-b1c7-4ab7-8a64-539e41e8e996	03300472-f68e-431d-a79f-4ac3cf81019f	Sports Nutrition	sports-nutrition	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
35f5a80c-5c01-4d1b-9ada-60967b50e124	03300472-f68e-431d-a79f-4ac3cf81019f	Sports Therapy	sports-therapy-sports-exercise	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
18c2d4d2-aff4-45d9-87b6-a9e877a878a6	03300472-f68e-431d-a79f-4ac3cf81019f	Sports Rehabilitation	sports-rehabilitation-sports-exercise	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a85fbaab-bcb8-44fe-b87c-923ac4559478	03300472-f68e-431d-a79f-4ac3cf81019f	Physical Education	physical-education	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7c20272e-7388-48f0-b358-c6750a63dcf0	03300472-f68e-431d-a79f-4ac3cf81019f	Physical Activity	physical-activity	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cc6fd8e6-430e-48af-bcf0-4c60b1c20050	03300472-f68e-431d-a79f-4ac3cf81019f	Kinesiology	kinesiology	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5551c48c-29be-4c7a-b420-006550caf19a	03300472-f68e-431d-a79f-4ac3cf81019f	Human Movement	human-movement	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3901ea4e-ae82-45c7-8776-01ea4c5e7074	03300472-f68e-431d-a79f-4ac3cf81019f	Athletic Training	athletic-training	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
dcc04191-58f5-4767-8d47-210f58788c06	03300472-f68e-431d-a79f-4ac3cf81019f	Sport Business	sport-business	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
edeccf95-6bc2-4e16-a855-162d7fb2533d	03300472-f68e-431d-a79f-4ac3cf81019f	Sport Marketing	sport-marketing	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0d655556-d513-4265-9012-35790dfa4a3b	03300472-f68e-431d-a79f-4ac3cf81019f	Sports Journalism	sports-journalism-sports-exercise	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5c0a89a3-debb-470e-9d68-e45146529e9c	03300472-f68e-431d-a79f-4ac3cf81019f	Sports Analytics	sports-analytics	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d1478a3d-6f9f-4a96-bbf1-97d06e86c374	03300472-f68e-431d-a79f-4ac3cf81019f	Esports	esports-sports-exercise	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
14a60893-a941-44e1-a9c3-0b10f30b9dfd	03300472-f68e-431d-a79f-4ac3cf81019f	Esports Management	esports-management-sports-exercise	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
756d030e-fa0f-47a2-8afe-e259d689a105	03300472-f68e-431d-a79f-4ac3cf81019f	Outdoor Education	outdoor-education	\N	f	published	23	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2c6541a2-3bc5-46fa-a6d2-40b96b51f6d2	03300472-f68e-431d-a79f-4ac3cf81019f	Adventure Sports	adventure-sports	\N	f	published	24	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3411d06c-66b4-4adc-a3d6-2561a552cb97	88de387b-7974-4c1e-80cc-9cfe95fd660a	Psychology	psychology-psychology-behavioural-sciences	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4d17d893-2763-4c1c-b38a-126d2038c465	88de387b-7974-4c1e-80cc-9cfe95fd660a	Clinical Psychology	clinical-psychology	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cb6a4e6d-3ce9-491c-9155-1f2001f07b70	88de387b-7974-4c1e-80cc-9cfe95fd660a	Counselling Psychology	counselling-psychology	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2e76ae84-380e-4cb8-b9c1-01dd622347fa	88de387b-7974-4c1e-80cc-9cfe95fd660a	Educational Psychology	educational-psychology-psychology-behavioural-sciences	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fab66f97-ca31-494b-add5-cd9c65994a15	88de387b-7974-4c1e-80cc-9cfe95fd660a	Forensic Psychology	forensic-psychology	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2d1b5de3-392f-47ef-9abc-2b9630c6a8f5	88de387b-7974-4c1e-80cc-9cfe95fd660a	Health Psychology	health-psychology	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
81742ed4-5f6c-4a4a-b9ef-4318a2e636e4	88de387b-7974-4c1e-80cc-9cfe95fd660a	Occupational Psychology	occupational-psychology	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
bccca5dc-a933-4f3a-8a8a-91efe8625cf4	88de387b-7974-4c1e-80cc-9cfe95fd660a	Organisational Psychology	organisational-psychology	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
052fa3b7-0dae-4993-8e0f-b16af8d10e5a	88de387b-7974-4c1e-80cc-9cfe95fd660a	Social Psychology	social-psychology	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4a597eb2-f9f9-489d-898a-d9f88a741b37	88de387b-7974-4c1e-80cc-9cfe95fd660a	Developmental Psychology	developmental-psychology	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
26754795-1e47-46cd-b125-e7fc05a1a19d	88de387b-7974-4c1e-80cc-9cfe95fd660a	Cognitive Psychology	cognitive-psychology	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f9745a00-f121-4546-8745-02554950ee05	88de387b-7974-4c1e-80cc-9cfe95fd660a	Neuropsychology	neuropsychology	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
278cdb14-cf5d-4615-8ea3-4c26228dbbd8	88de387b-7974-4c1e-80cc-9cfe95fd660a	Behavioural Psychology	behavioural-psychology	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1f66873f-0aeb-46f6-9993-31adbed15aa9	88de387b-7974-4c1e-80cc-9cfe95fd660a	Child Psychology	child-psychology	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cc3f37c1-8607-4b0f-9e98-d689b5aad33b	88de387b-7974-4c1e-80cc-9cfe95fd660a	Applied Psychology	applied-psychology	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ff27ff8c-3319-4f0f-940d-e6f1995122fc	88de387b-7974-4c1e-80cc-9cfe95fd660a	Sport Psychology	sport-psychology	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
31f38059-29b4-4814-9b75-1dd4ed385e7a	88de387b-7974-4c1e-80cc-9cfe95fd660a	Mental Health Studies	mental-health-studies	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
bc4d6ed2-75ab-45d1-a185-3a3fab23cba0	88de387b-7974-4c1e-80cc-9cfe95fd660a	Counselling	counselling-psychology-behavioural-sciences	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
dac8a0c3-7106-463e-9e19-ae9e1ff6dfe8	88de387b-7974-4c1e-80cc-9cfe95fd660a	Psychotherapy	psychotherapy	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b961450f-2483-4c1c-b29f-21d33a752f23	88de387b-7974-4c1e-80cc-9cfe95fd660a	Behavioural Science	behavioural-science	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3dff41bf-b260-4e11-a2c8-b4fabccd212f	88de387b-7974-4c1e-80cc-9cfe95fd660a	Cognitive Science	cognitive-science-psychology-behavioural-sciences	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
31f40a63-8aac-4012-936a-70a6ffa39a08	88de387b-7974-4c1e-80cc-9cfe95fd660a	Neuroscience	neuroscience-psychology-behavioural-sciences	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d6566825-2150-4bfb-b7c1-4a3e2e150c68	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Fashion Design	fashion-design-fashion-textiles	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
95c490ae-10be-4fc7-a389-3451c150f7b1	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Fashion Management	fashion-management-fashion-textiles	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
bdbb82a6-9867-47ba-8f55-b59eb8750c79	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Fashion Marketing	fashion-marketing	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
dd9eb4e9-f243-43a0-b493-630b6ca57de3	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Fashion Business	fashion-business	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
149eefa8-9a1b-47de-b451-f52493e4f306	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Fashion Buying	fashion-buying	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d39bdbb3-27cc-43dc-8510-88ff31ee6abd	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Fashion Merchandising	fashion-merchandising-fashion-textiles	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ef4d7cfb-44da-4d10-9ba6-f3edbe9f755d	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Fashion Communication	fashion-communication	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ea95522d-3594-4185-b607-8db075d2426f	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Fashion Styling	fashion-styling-fashion-textiles	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c10b823c-4e2a-447f-8b38-da711b2eaa03	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Fashion Journalism	fashion-journalism	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3997bc86-b870-4013-bd3a-a917e7d05f19	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Fashion Technology	fashion-technology-fashion-textiles	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5d774024-b114-40a7-a84b-ee3925174dac	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Textile Design	textile-design-fashion-textiles	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
818e3c70-bbf6-4842-bd28-6aa095267664	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Textile Technology	textile-technology	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4af09e6d-9d6f-4e5a-8d57-720168f7ea89	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Textile Science	textile-science	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d321026f-b337-4f72-a2ed-737976b95fa0	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Apparel Design	apparel-design	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
278e02c1-7c61-4d54-8486-710d076c49f7	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Apparel Technology	apparel-technology	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7e42ca9b-1ac9-45b8-907b-c46bbfc1953e	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Luxury Fashion	luxury-fashion	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
32296b68-ed18-43b3-aaa9-358ef238950c	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Fashion Sustainability	fashion-sustainability	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
190bc863-40e6-4d42-a47e-af4d7e3a6260	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Costume Design	costume-design	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0f758137-6a15-42ff-8fb8-f5a31736b89c	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Footwear Design	footwear-design	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7620b7d0-14aa-4bbd-8ab3-3907218e3a68	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Jewellery Design	jewellery-design-fashion-textiles	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c112e8e5-aa09-4b7e-bc53-c31d85781056	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	Culinary Arts	culinary-arts-hospitality-culinary-food	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d459fd05-fefb-4387-9c9b-7641882061c5	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	Culinary Management	culinary-management	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
56ca6ee6-f5c7-47ca-b554-fe88889bf9a6	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	Food & Beverage Management	food-beverage-management-hospitality-culinary-food	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c91c8d4a-e696-4c58-94de-e7e2cad3cb44	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	Food Technology	food-technology-hospitality-culinary-food	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1d2d6c6a-a383-4008-907f-aa8504e08e8f	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	Food Science	food-science-hospitality-culinary-food	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c02878a0-692b-4c8a-bd77-6514da221645	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	Food Safety	food-safety	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d79e8b6b-6ac4-4e0b-99a7-145f140c7994	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	Food Nutrition	food-nutrition	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
46edfbad-f135-474a-9ac7-d23a1209388d	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	Professional Cookery	professional-cookery-hospitality-culinary-food	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9142efcf-34f6-4d06-98ca-6f83495ebd28	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	Baking	baking	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ba257db4-6cb7-4dd2-8815-d6e790093fde	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	Patisserie	patisserie	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3bd2914e-fc0a-4232-8a8b-5cb998ba66b8	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	Bakery	bakery	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d8810a56-37c4-484d-bb78-3a1957e3c6d2	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	Restaurant Management	restaurant-management-hospitality-culinary-food	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
36e2e7ca-9261-424e-a6e0-cdcd12f3081f	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	Hospitality	hospitality	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5c1a4a3a-b93f-4fcd-b927-6f6419347525	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	Hotel Management	hotel-management-hospitality-culinary-food	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
18a2d9db-4401-4989-8a76-ab3838d8d0e5	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	Resort Management	resort-management-hospitality-culinary-food	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f9760977-cbb1-4ca2-8e75-356e8bc4c5a2	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	Catering Management	catering-management	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8b1e797b-e1fb-42db-b8f1-29f2d5e54a3b	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	Aviation	aviation	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8f2926a9-3a7a-4a20-8239-abfb88b98769	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	Aviation Management	aviation-management-aviation-aerospace	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cf423664-7d89-4e48-860e-024c371f41ae	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	Airport Management	airport-management	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0400ceac-e274-4621-84fd-94da5777a2de	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	Airline Management	airline-management	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e5b3f363-e38b-432d-acf0-09a3259b2abd	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	Aviation Operations	aviation-operations	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1a0fd8f0-ee44-413d-a9cc-acaeda35b9e3	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	Aviation Safety	aviation-safety	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c30b42c3-56b8-4c43-ad24-198ac3a7d26f	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	Airline Operations	airline-operations	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fc600714-45c3-4c63-8ba1-2389a643f9c9	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	Air Transport Management	air-transport-management	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8d40eceb-3aad-4d0b-9c89-302dd5014683	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	Aeronautical Engineering	aeronautical-engineering-aviation-aerospace	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b19c566e-9b74-4bbb-b886-d996d6f5e093	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	Aerospace Engineering	aerospace-engineering-aviation-aerospace	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
499f09c5-5525-4600-a094-5029d1583cb9	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	Aircraft Maintenance	aircraft-maintenance	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
93ae8252-2b08-431f-9c99-ae9679f94bc6	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	Aircraft Engineering	aircraft-engineering	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ba6bb2aa-4184-452f-8a4e-fb47bc3a9835	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	Pilot Training	pilot-training	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1622fc03-f673-402d-893e-992697397b0f	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	Commercial Pilot Training	commercial-pilot-training	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
94b57777-6d72-4460-bf10-41e85bbdee94	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	Aviation Technology	aviation-technology	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
917f65cc-37c4-4ce8-9908-10fc594be03e	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	Air Traffic Management	air-traffic-management	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b3b12f95-ef66-4638-918e-1147b4864452	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	Aviation Security	aviation-security-aviation-aerospace	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2636aaec-a3ee-424f-811e-1d81d60cca95	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	Maritime Studies	maritime-studies	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d874fde2-df0f-442f-a35c-bcf2e0e28844	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	Maritime Management	maritime-management	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9be401b9-f680-46cc-a93d-3f9bc8dec817	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	Maritime Business	maritime-business	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9084fe8d-4da1-4da4-8e93-20be62457310	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	Shipping	shipping-maritime-shipping	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
698fd2f4-5bbc-462c-b980-8ebb5556cc7f	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	Shipping Management	shipping-management	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
33147c13-8c8e-4711-865f-7f1756e1bf67	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	Port Management	port-management-maritime-shipping	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
979bd526-d353-4cc4-b5ba-a44f4c3e57fb	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	Marine Engineering	marine-engineering-maritime-shipping	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b1a92c1c-1a22-4d0d-b31e-8a14e9a5ad4c	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	Naval Architecture	naval-architecture-maritime-shipping	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a9791ee5-8e01-432d-bb22-bd8b8cb5f600	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	Marine Technology	marine-technology	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8ce12be8-9c6b-4540-9ba6-83e7845bb5a0	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	Maritime Law	maritime-law-maritime-shipping	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1d2fa57f-bfd9-46bc-898b-bc6d62735083	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	Maritime Logistics	maritime-logistics-maritime-shipping	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cff7b015-b52e-4279-8cff-2810728c8974	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	Ocean Engineering	ocean-engineering	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
35072328-653c-44dd-9a51-a8143a49ee04	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	Offshore Engineering	offshore-engineering-maritime-shipping	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f4cf7700-f848-49a1-964a-ee7ffd9acf3c	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	Marine Science	marine-science-maritime-shipping	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
38c00a1c-031c-4e00-af17-c88fc82966b1	0104cd86-3a4b-4efb-9146-cb45541c0e64	Film Production	film-production-media-entertainment-gaming	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
75f0c7ac-7d38-4fa8-93ed-76de7228f749	0104cd86-3a4b-4efb-9146-cb45541c0e64	Film Studies	film-studies-media-entertainment-gaming	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
69bbabcc-990d-4546-811e-679c23bad1ac	0104cd86-3a4b-4efb-9146-cb45541c0e64	Television Production	television-production-media-entertainment-gaming	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
15fb57c1-ea63-4470-a786-23a8e2296cd6	0104cd86-3a4b-4efb-9146-cb45541c0e64	Media Production	media-production-media-entertainment-gaming	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
280e1a0e-53a0-4922-b50d-03de03773613	0104cd86-3a4b-4efb-9146-cb45541c0e64	Digital Media	digital-media-media-entertainment-gaming	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0893cb2a-4e28-49e5-ac68-a5d2820eb17b	0104cd86-3a4b-4efb-9146-cb45541c0e64	Animation	animation-media-entertainment-gaming	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3182243c-54d0-493c-9dbe-86a5b3db21a1	0104cd86-3a4b-4efb-9146-cb45541c0e64	Game Design	game-design-media-entertainment-gaming	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ca401d21-fc2b-4033-8c66-9d4cc5994973	0104cd86-3a4b-4efb-9146-cb45541c0e64	Game Development	game-development-media-entertainment-gaming	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e8a9f5dd-732a-4aa4-926f-82dea3a3fa7c	0104cd86-3a4b-4efb-9146-cb45541c0e64	Game Programming	game-programming	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fac57b79-25e0-40b4-bd40-d7ea23392062	0104cd86-3a4b-4efb-9146-cb45541c0e64	Game Art	game-art	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f5273b98-0805-48f2-b249-a3886bce6f9d	0104cd86-3a4b-4efb-9146-cb45541c0e64	Game Technology	game-technology	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
327d157c-a0dd-4b8d-a8bb-2edf8515a014	0104cd86-3a4b-4efb-9146-cb45541c0e64	Esports	esports-media-entertainment-gaming	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cd740225-fb3d-459e-a9e0-2afc386060d2	0104cd86-3a4b-4efb-9146-cb45541c0e64	Esports Management	esports-management-media-entertainment-gaming	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e16d7269-6ac6-4a76-bcf7-e838870ad49e	0104cd86-3a4b-4efb-9146-cb45541c0e64	Visual Effects	visual-effects-media-entertainment-gaming	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7756daf8-e1a7-42a1-8134-ae5e362740c7	0104cd86-3a4b-4efb-9146-cb45541c0e64	VFX	vfx-media-entertainment-gaming	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
32da0660-78d6-4c0f-9a67-7331d976ef32	0104cd86-3a4b-4efb-9146-cb45541c0e64	3D Animation	3d-animation-media-entertainment-gaming	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0f664edf-8bf6-4ed1-ac57-fa5a4389cb61	0104cd86-3a4b-4efb-9146-cb45541c0e64	Motion Graphics	motion-graphics-media-entertainment-gaming	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0eaf4e5f-3212-42cb-8c5b-abff97eb9a6a	0104cd86-3a4b-4efb-9146-cb45541c0e64	Sound Design	sound-design-media-entertainment-gaming	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
87b1e279-a866-4f37-a6f4-3b1c9aaa2c2b	0104cd86-3a4b-4efb-9146-cb45541c0e64	Music Production	music-production-media-entertainment-gaming	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
17e63f7d-acc1-478a-aabb-78a3030bd500	0104cd86-3a4b-4efb-9146-cb45541c0e64	Music Business	music-business	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ee1b2443-42c9-4569-a3f4-54c511015dd8	0104cd86-3a4b-4efb-9146-cb45541c0e64	Entertainment Management	entertainment-management	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f25a19b8-34ee-4760-899e-566b540aba90	0104cd86-3a4b-4efb-9146-cb45541c0e64	Theatre	theatre-media-entertainment-gaming	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a83e6455-bde2-47ab-aa04-147b5a25ce27	0104cd86-3a4b-4efb-9146-cb45541c0e64	Performing Arts	performing-arts-media-entertainment-gaming	\N	f	published	23	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ad915fdc-0b41-41dc-9ded-22ab7799b255	0104cd86-3a4b-4efb-9146-cb45541c0e64	Acting	acting-media-entertainment-gaming	\N	f	published	24	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
626e7b7f-9663-43ac-9ccb-9f1fc6d376fd	0104cd86-3a4b-4efb-9146-cb45541c0e64	Screenwriting	screenwriting-media-entertainment-gaming	\N	f	published	25	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
87105c30-4a18-4e71-83c1-cea256997f1d	bd852326-e555-450e-82c2-bef3f76b6e92	International Relations	international-relations-public-policy-government-international-studies	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
24b64bd1-1e0f-44d5-ac38-cc6e9f2d8861	bd852326-e555-450e-82c2-bef3f76b6e92	International Development	international-development-public-policy-government-international-studies	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9b7ed410-2565-4792-adce-65f4d594eacd	bd852326-e555-450e-82c2-bef3f76b6e92	Political Science	political-science-public-policy-government-international-studies	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0b6a255f-58ec-4057-8926-f7d12effd3d5	bd852326-e555-450e-82c2-bef3f76b6e92	Politics	politics-public-policy-government-international-studies	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4abe2dbb-8fb9-44ce-b454-727ef33c17e5	bd852326-e555-450e-82c2-bef3f76b6e92	Public Policy	public-policy-public-policy-government-international-studies	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
477f1bc1-bf4a-4d58-9207-ced569820909	bd852326-e555-450e-82c2-bef3f76b6e92	Public Administration	public-administration-public-policy-government-international-studies	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
795ce52f-8efc-4819-b204-0930f7bfeff8	bd852326-e555-450e-82c2-bef3f76b6e92	Governance	governance	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
dde0b892-b5d4-4797-a1cc-eada12517eb7	bd852326-e555-450e-82c2-bef3f76b6e92	Global Governance	global-governance	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
31a79b27-a5d1-4e20-8a73-e49fe626b072	bd852326-e555-450e-82c2-bef3f76b6e92	Diplomacy	diplomacy	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ae5d6e6d-25bd-405c-a34c-cde82eaf5ff4	bd852326-e555-450e-82c2-bef3f76b6e92	International Affairs	international-affairs	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c50beba6-dc6e-459a-bd22-dec623e459ca	bd852326-e555-450e-82c2-bef3f76b6e92	Development Studies	development-studies-public-policy-government-international-studies	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d2371512-ed69-4b5d-bb3f-cbc1966d55a0	bd852326-e555-450e-82c2-bef3f76b6e92	International Security	international-security-public-policy-government-international-studies	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e405a739-b4d8-41cb-a375-9ed520584f7c	bd852326-e555-450e-82c2-bef3f76b6e92	Strategic Studies	strategic-studies-public-policy-government-international-studies	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3bbdab19-dbed-4b6e-be93-4b49de1a7468	bd852326-e555-450e-82c2-bef3f76b6e92	Peace Studies	peace-studies	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3faba3a8-1469-4451-8580-5c3d210d69df	bd852326-e555-450e-82c2-bef3f76b6e92	Conflict Studies	conflict-studies	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a4153bbf-976a-43ba-aff1-39f9cd5e7d4d	bd852326-e555-450e-82c2-bef3f76b6e92	Human Rights	human-rights	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
834bee44-996e-46a8-b34b-574fab06e1b0	bd852326-e555-450e-82c2-bef3f76b6e92	Migration Studies	migration-studies-public-policy-government-international-studies	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e5405daa-9f92-4432-b5ed-8ae18b7f4083	bd852326-e555-450e-82c2-bef3f76b6e92	European Studies	european-studies	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7763fdc2-0179-4024-998d-efb84b8c72d9	bd852326-e555-450e-82c2-bef3f76b6e92	International Studies	international-studies-public-policy-government-international-studies	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b147439c-c934-452b-bb69-dbd896946e1a	bd852326-e555-450e-82c2-bef3f76b6e92	Public Management	public-management	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
df5ff487-2d1c-49c3-b767-840530259c1b	bd852326-e555-450e-82c2-bef3f76b6e92	Government Studies	government-studies	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f5f6b0f0-fa26-4428-bff4-3dfff86ee767	bd852326-e555-450e-82c2-bef3f76b6e92	Defence Studies	defence-studies-public-policy-government-international-studies	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f3b2a10f-38e3-4331-9079-fd6e6c23fc78	bd852326-e555-450e-82c2-bef3f76b6e92	Intelligence Studies	intelligence-studies-public-policy-government-international-studies	\N	f	published	23	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d4e4478a-cc4d-41e1-b667-8f814ebabc92	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Economics	economics-economics-finance	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0a971106-fdea-4d5f-ab18-8febb06a4cdb	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Applied Economics	applied-economics	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3c0538c5-3ce7-42f0-811a-c08e2db38287	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Financial Economics	financial-economics	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7ea3d5ac-d84e-4baf-997a-fa11b7917eea	16ac725d-d1b0-48b0-927f-6c3743de8ba0	International Economics	international-economics	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
55b7bde1-4937-4bf4-a898-c5498ca068e5	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Development Economics	development-economics	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1748fc97-d522-449d-8c64-9c8e9e7a3490	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Behavioural Economics	behavioural-economics	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ec7328cb-7557-4627-80ae-1cf1e34c9e23	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Econometrics	econometrics-economics-finance	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
01049ac5-3d16-44a0-b745-88d6f3e0b293	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Finance	finance-economics-finance	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b29be2ee-b4c2-44f1-8443-ed438e63a8ee	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Banking	banking-economics-finance	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a949c2d5-4b11-4a4b-a675-4e0c66c8d890	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Investment Banking	investment-banking	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
96cd1285-f2cf-4259-8f56-18154b5c7818	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Corporate Finance	corporate-finance	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9cd87c24-d5d3-4914-9938-e12e0eb08464	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Financial Management	financial-management-economics-finance	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
bb251873-7af9-4a51-b96f-01df62c3a63e	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Financial Markets	financial-markets	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c23c036e-291a-48b7-86b4-3442e853889a	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Investment Management	investment-management-economics-finance	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e1fe60c7-4918-41a2-9587-435223ec62c1	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Wealth Management	wealth-management	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0c0112ac-bd9a-4252-a644-3d52c09c26de	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Asset Management	asset-management	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
79f8267d-860c-496f-92f5-8f46004fa686	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Risk Management	risk-management-economics-finance	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a7fb7a56-fb84-4eed-b9ec-3c89f2d95e03	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Financial Technology	financial-technology-economics-finance	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
97beff0d-4241-4f74-b7f7-5e4abcd3fad8	16ac725d-d1b0-48b0-927f-6c3743de8ba0	FinTech	fintech-economics-finance	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
81316f5f-1d95-404a-9a23-3e1cc1a833c2	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Accounting	accounting-economics-finance	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c4bc75bb-be8e-4b94-9275-3cd484aa1b25	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Accounting & Finance	accounting-finance-economics-finance	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b836ef3a-f0bc-46be-ae84-8ae0b439d819	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Auditing	auditing-economics-finance	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7b43f703-8f5e-46b3-b2c0-9808b91b8061	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Taxation	taxation-economics-finance	\N	f	published	23	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4b8d5cef-6b0a-46af-9e16-e7b74fc346cc	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Actuarial Science	actuarial-science-economics-finance	\N	f	published	24	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ebbadf54-2696-485a-b864-dbc047456e89	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Insurance	insurance-economics-finance	\N	f	published	25	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
bd70a67b-361a-4312-8441-23c57e97624d	16ac725d-d1b0-48b0-927f-6c3743de8ba0	Financial Planning	financial-planning	\N	f	published	26	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6bc2f2f4-d718-480b-9c4d-bedc0f554e3f	90b7c9bd-2e27-4cd0-ba71-0739f269a104	Mathematics	mathematics-mathematics-statistics	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
634089ad-175e-4918-b996-a72f48ba5f25	90b7c9bd-2e27-4cd0-ba71-0739f269a104	Applied Mathematics	applied-mathematics-mathematics-statistics	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ddf4bc17-90b1-4197-9c5a-64e03d6da5b2	90b7c9bd-2e27-4cd0-ba71-0739f269a104	Pure Mathematics	pure-mathematics	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
815364fb-9866-41f8-8944-0b8aeb9f25f0	90b7c9bd-2e27-4cd0-ba71-0739f269a104	Statistics	statistics-mathematics-statistics	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8bb49b61-ac15-44e5-a0b5-ac523604de1b	90b7c9bd-2e27-4cd0-ba71-0739f269a104	Applied Statistics	applied-statistics	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b773454d-bc51-4b69-923c-f11cf90c191d	90b7c9bd-2e27-4cd0-ba71-0739f269a104	Mathematical Finance	mathematical-finance	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
871b491b-1195-4425-8fcc-6f446ca7c4b4	90b7c9bd-2e27-4cd0-ba71-0739f269a104	Financial Mathematics	financial-mathematics	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
24ed6fd4-9eac-439d-9c51-6ce3a3debf5a	90b7c9bd-2e27-4cd0-ba71-0739f269a104	Actuarial Mathematics	actuarial-mathematics	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a5bac145-8f44-4bd1-8b84-b8da335a206c	90b7c9bd-2e27-4cd0-ba71-0739f269a104	Data Science	data-science-mathematics-statistics	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
10c7c8e8-3b3e-4947-a5bc-baaf796f62a3	90b7c9bd-2e27-4cd0-ba71-0739f269a104	Data Analytics	data-analytics-mathematics-statistics	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e41ff71a-4d9e-4fb4-867f-9f7f5be7f386	90b7c9bd-2e27-4cd0-ba71-0739f269a104	Econometrics	econometrics-mathematics-statistics	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fed2b308-f2e7-49ad-a072-b551f50c27f4	90b7c9bd-2e27-4cd0-ba71-0739f269a104	Operational Research	operational-research	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5904a0de-337a-484e-a1cd-3da25f6ef75b	90b7c9bd-2e27-4cd0-ba71-0739f269a104	Computational Mathematics	computational-mathematics	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
95313035-4c2a-406f-8e01-58365d33d89c	90b7c9bd-2e27-4cd0-ba71-0739f269a104	Mathematical Modelling	mathematical-modelling	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d0efe7a8-bf98-4b66-8347-aeb4779d6c7b	90b7c9bd-2e27-4cd0-ba71-0739f269a104	Biostatistics	biostatistics	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6be16f90-aa0b-4292-a4b1-085f16dda833	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Biology	biology-biological-life-sciences	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1acf3748-a10f-409f-a00f-c7c22b1270bd	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Biochemistry	biochemistry-biological-life-sciences	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c347a641-2ea5-4bc6-a7a6-977b6f56e7f1	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Biotechnology	biotechnology-biological-life-sciences	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4833b13d-a443-4546-8119-67fbe95a74a1	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Microbiology	microbiology-biological-life-sciences	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
48f2ad13-ef40-4c3c-b8f3-ca21c9382485	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Molecular Biology	molecular-biology-biological-life-sciences	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
23c88dd7-58be-4c1f-8181-15fccbf08b1e	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Molecular Microbiology	molecular-microbiology-biological-life-sciences	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
dc41d5cc-f03c-49f7-8f3a-79cb0ec4aaf7	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Cell Biology	cell-biology-biological-life-sciences	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
bc200d70-1e7a-4d8a-92cf-889392a226b3	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Molecular Cell Biology	molecular-cell-biology-biological-life-sciences	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d8219a77-4af5-4454-bf49-9bef6dfdf8cf	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Genetics	genetics-biological-life-sciences	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
828b1e88-7ae4-4f07-b263-cd5be43e5c1e	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Genomics	genomics	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
83dd7bbe-ba0c-498d-837b-fdfec98aaa0d	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Biomedical Science	biomedical-science-biological-life-sciences	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
862ef363-8655-4bd5-a50d-a4a2bff225ad	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Neuroscience	neuroscience-biological-life-sciences	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a3358102-1fd9-4fe7-8b03-82de27d10c2b	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Immunology	immunology-biological-life-sciences	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fd2ab581-0d98-4141-a6e6-a9c3b2e89ba2	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Pharmacology	pharmacology-biological-life-sciences	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9c735df6-fd36-4a01-8366-1d68e5ebc529	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Physiology	physiology-biological-life-sciences	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9757996c-dfec-45b9-936a-55bd1b771857	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Anatomy	anatomy-biological-life-sciences	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
035a0778-4121-45d9-b69c-dc04f98d955b	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Zoology	zoology-biological-life-sciences	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
98a0475b-187b-4fea-ae0c-da3ad2b7ef73	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Botany	botany-biological-life-sciences	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
038f7fe5-2ec1-402d-996d-97a8aa5df0ca	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Plant Science	plant-science-biological-life-sciences	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a014dee5-eff9-4468-ac9d-fd62af946d05	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Animal Science	animal-science-biological-life-sciences	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2e280615-bb64-45af-908a-e4618ae5b3e7	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Marine Biology	marine-biology-biological-life-sciences	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f9671c24-017e-4281-a7b2-576dfe4a27a9	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Ecology	ecology-biological-life-sciences	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
95021efc-b367-4fae-b513-faf1e66d2f08	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Evolutionary Biology	evolutionary-biology	\N	f	published	23	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5181426a-317a-4478-8fd5-63e4fb2a2868	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Conservation Biology	conservation-biology-biological-life-sciences	\N	f	published	24	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d32fb6ea-7040-414a-844b-cebd2b4991fb	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Bioinformatics	bioinformatics-biological-life-sciences	\N	f	published	25	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
209f6688-be7d-4ba3-9f1f-c40ceb997299	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Computational Biology	computational-biology-biological-life-sciences	\N	f	published	26	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6f17eb14-3318-4fae-a4f4-04e25f9d79e9	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Biophysics	biophysics	\N	f	published	27	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
02f34628-b133-4330-978c-ae739d66ff88	7879f520-178b-4aa5-b6f7-c8db7486ca6b	Biomedical Engineering	biomedical-engineering-biological-life-sciences	\N	f	published	28	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e23c8dea-7210-4d9f-80f9-552ec900464a	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	Pharmacy	pharmacy	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e289eded-8d47-4750-975a-1744b7e17755	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	Pharmaceutical Science	pharmaceutical-science-pharmaceutical-pharmaceutical-sciences	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
93ef9878-863a-4055-a220-ad4c6ab3da30	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	Pharmaceutical Chemistry	pharmaceutical-chemistry-pharmaceutical-pharmaceutical-sciences	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7309629a-b0ba-4cb1-804d-0bb4982485e0	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	Pharmacology	pharmacology-pharmaceutical-pharmaceutical-sciences	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cbbe3985-c938-4ed0-8ee5-fc6208710b47	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	Drug Discovery	drug-discovery	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
40ed328a-8aab-4e83-aa56-49fa07df66b8	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	Drug Development	drug-development	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2fb21352-6a7a-4346-a183-c11b662499a7	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	Clinical Pharmacy	clinical-pharmacy	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9e92d518-54b8-4b6a-8377-9347a9b1566d	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	Industrial Pharmacy	industrial-pharmacy	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f5e62d2d-bbe9-4431-8fca-1caca7f8dcdc	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	Pharmaceutical Biotechnology	pharmaceutical-biotechnology	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1a5e9047-3aed-47bf-978b-183d29173f54	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	Pharmaceutical Technology	pharmaceutical-technology	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
388f1b35-998a-427c-95ab-5eb269e1e56e	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	Pharmacovigilance	pharmacovigilance	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7a2440e5-ca50-4356-9f50-7b10729d2881	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	Regulatory Affairs	regulatory-affairs	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e76bf089-b480-411f-a65f-7fd9c47c8494	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	Clinical Research	clinical-research	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b5e87b6e-8590-4866-b72b-d5d418e0b54f	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	Toxicology	toxicology-pharmaceutical-pharmaceutical-sciences	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0e2507c3-282a-43be-90fd-64517a1e807e	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	Medicinal Chemistry	medicinal-chemistry	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d7bb2d07-8daf-4d43-b16f-0d78a6beb420	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	Pharmaceutical Analysis	pharmaceutical-analysis	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2da52461-07c9-473f-b842-83ab4f5fe6ff	7985d638-c390-420e-a594-befe81db9621	Social Work	social-work-social-work-community-services	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9730b43f-b884-440e-b37a-bb77b75421f2	7985d638-c390-420e-a594-befe81db9621	Community Development	community-development-social-work-community-services	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fade84cd-0509-4288-8b2f-a6dbae4e11db	7985d638-c390-420e-a594-befe81db9621	Youth Work	youth-work	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
326b3cec-221e-4a56-a888-d10966abf256	7985d638-c390-420e-a594-befe81db9621	Community Services	community-services	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4332b5bf-812b-45b9-81c5-2fad4a3bec69	7985d638-c390-420e-a594-befe81db9621	Human Services	human-services	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f62802eb-e1d8-4108-960e-3cda924737a2	7985d638-c390-420e-a594-befe81db9621	Social Policy	social-policy-social-work-community-services	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
18dfaa53-4eff-4b5f-a5b2-61887cda135d	7985d638-c390-420e-a594-befe81db9621	Social Care	social-care	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a7e46d04-8fa2-4d24-9259-40b1a0fb360a	7985d638-c390-420e-a594-befe81db9621	Childcare	childcare	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
986f2832-6826-4cf6-b665-58be6ec71f91	7985d638-c390-420e-a594-befe81db9621	Child Development	child-development-social-work-community-services	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7115cfa0-0b0e-45c1-b6b0-13875e54444c	7985d638-c390-420e-a594-befe81db9621	Family Studies	family-studies	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3a061c2e-c3bb-412c-8b50-244ffec78015	7985d638-c390-420e-a594-befe81db9621	Gerontology	gerontology	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a0129259-50b1-4d96-8d67-3545bfd92922	7985d638-c390-420e-a594-befe81db9621	Disability Studies	disability-studies	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ae028944-5acc-40cd-9713-ac7ca91ea817	7985d638-c390-420e-a594-befe81db9621	Counselling	counselling-social-work-community-services	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
231df96e-fe3c-4ed5-b0aa-eb0c6389d2dc	7985d638-c390-420e-a594-befe81db9621	Mental Health	mental-health	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fa94be3f-6abd-437f-a3a8-b6ecfb75d709	7985d638-c390-420e-a594-befe81db9621	Community Health	community-health	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c7a81287-e09f-4594-94fe-85f652f5c81d	7985d638-c390-420e-a594-befe81db9621	Addiction Studies	addiction-studies	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0781d180-fb72-4862-a721-9149e1e53f96	7985d638-c390-420e-a594-befe81db9621	Rehabilitation Studies	rehabilitation-studies	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
52f6ed17-303e-4f38-a570-44d9a3ed32e5	7f6682ba-7ae6-439b-a99e-af8135f9995f	Logistics	logistics-transport-logistics	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d4cea336-ab99-473d-a0fb-32cd85824da2	7f6682ba-7ae6-439b-a99e-af8135f9995f	Supply Chain Management	supply-chain-management-transport-logistics	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9472f80b-3b80-4f39-91c8-63ea96cae736	7f6682ba-7ae6-439b-a99e-af8135f9995f	Procurement	procurement-transport-logistics	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8c9e93b2-8bb8-4857-b122-5cbc182d0b1b	7f6682ba-7ae6-439b-a99e-af8135f9995f	Transport Management	transport-management	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7036f7e8-a331-4758-9066-9bf69aa63d7b	7f6682ba-7ae6-439b-a99e-af8135f9995f	Transportation Planning	transportation-planning	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a226b537-a8ae-492e-bae4-a72652409e57	7f6682ba-7ae6-439b-a99e-af8135f9995f	Logistics Management	logistics-management	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
53078e1a-56d7-40ec-8a51-ee6ccc2231a6	7f6682ba-7ae6-439b-a99e-af8135f9995f	International Logistics	international-logistics	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
943baa91-7e21-4cd0-9bbf-e32c8a246418	7f6682ba-7ae6-439b-a99e-af8135f9995f	Shipping	shipping-transport-logistics	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
69fdeae4-9108-4a9c-b9f5-1a723ab405aa	7f6682ba-7ae6-439b-a99e-af8135f9995f	Maritime Logistics	maritime-logistics-transport-logistics	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9e0a4eea-3f90-4521-af61-00eda5957adc	7f6682ba-7ae6-439b-a99e-af8135f9995f	Aviation Management	aviation-management-transport-logistics	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
4216a849-2aa1-48e0-9311-093eb9b3f6be	7f6682ba-7ae6-439b-a99e-af8135f9995f	Port Management	port-management-transport-logistics	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8bc22171-a54c-429e-9c31-ec6e2fa4fd9e	7f6682ba-7ae6-439b-a99e-af8135f9995f	Railway Management	railway-management	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9725ad26-d15b-4f1a-941e-36296b2a7c87	7f6682ba-7ae6-439b-a99e-af8135f9995f	Fleet Management	fleet-management	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
540bcf19-06f0-4ab7-98d2-dca8227d74ef	7f6682ba-7ae6-439b-a99e-af8135f9995f	Operations Management	operations-management-transport-logistics	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d16c2589-ca27-4dd9-8812-285b41ae3a41	7f6682ba-7ae6-439b-a99e-af8135f9995f	Procurement & Supply	procurement-supply	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f5b5dfb6-9b9a-4355-bb94-9b52f3848cc3	7f6682ba-7ae6-439b-a99e-af8135f9995f	Global Supply Chain	global-supply-chain	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
24907bf8-ed45-4008-b6c8-0a50d7c3641b	7f6682ba-7ae6-439b-a99e-af8135f9995f	Warehouse Management	warehouse-management	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
822f733d-9e9b-469a-9502-9afd927a8256	b887195b-f5fd-4a21-b1dd-35f5e689323b	Energy Engineering	energy-engineering-energy-oil-gas	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0fb1ddf7-dc5d-421c-9c87-a6e3832a9c42	b887195b-f5fd-4a21-b1dd-35f5e689323b	Renewable Energy	renewable-energy-energy-oil-gas	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
260ac63f-c67a-4916-a480-31f20c94d93a	b887195b-f5fd-4a21-b1dd-35f5e689323b	Sustainable Energy	sustainable-energy	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
863b8c73-3258-41cf-98cd-5a96120a425f	b887195b-f5fd-4a21-b1dd-35f5e689323b	Energy Management	energy-management	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
550d36d2-d7df-40a2-85f2-3392e28713da	b887195b-f5fd-4a21-b1dd-35f5e689323b	Energy Policy	energy-policy	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
132625bf-36f3-4cb4-8a57-ffec37953e6e	b887195b-f5fd-4a21-b1dd-35f5e689323b	Solar Energy	solar-energy	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e90a221f-ce29-4ccb-9b58-80ac9e206e5a	b887195b-f5fd-4a21-b1dd-35f5e689323b	Wind Energy	wind-energy	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ce3e515c-01b9-49b3-ad34-5b313dc7d651	b887195b-f5fd-4a21-b1dd-35f5e689323b	Nuclear Energy	nuclear-energy	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
715e8598-daa5-4cc8-a7b9-b9962f32bf82	b887195b-f5fd-4a21-b1dd-35f5e689323b	Petroleum Engineering	petroleum-engineering-energy-oil-gas	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7a110191-66ba-4521-9778-ea4c2346aa6c	b887195b-f5fd-4a21-b1dd-35f5e689323b	Oil & Gas Engineering	oil-gas-engineering-energy-oil-gas	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5e00c401-584f-40ec-b5d6-932919d5eed7	b887195b-f5fd-4a21-b1dd-35f5e689323b	Oil & Gas Management	oil-gas-management	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
53430fc2-0311-4769-a343-27d32db9015b	b887195b-f5fd-4a21-b1dd-35f5e689323b	Petroleum Geology	petroleum-geology	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a244d294-53ea-47d2-b5d9-c7f746d965a4	b887195b-f5fd-4a21-b1dd-35f5e689323b	Energy Economics	energy-economics	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7d040665-263b-4873-bc3b-aa6c2a848a72	b887195b-f5fd-4a21-b1dd-35f5e689323b	Offshore Engineering	offshore-engineering-energy-oil-gas	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a79ebbf3-3591-499b-b65b-093a5cfccb95	b887195b-f5fd-4a21-b1dd-35f5e689323b	Mining Engineering	mining-engineering-energy-oil-gas	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d8dc8ea8-309d-4e29-8922-03a060dd9dbe	b887195b-f5fd-4a21-b1dd-35f5e689323b	Mineral Engineering	mineral-engineering	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
09299f26-6535-4390-90ee-183c2fc85450	b887195b-f5fd-4a21-b1dd-35f5e689323b	Geothermal Energy	geothermal-energy	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1d32376b-6304-44f6-bd72-1c0fdc00975a	b887195b-f5fd-4a21-b1dd-35f5e689323b	Hydrogen Energy	hydrogen-energy	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7806e745-a80d-40cf-b907-401c0bb469e0	ef8c3004-6633-407a-a524-466abc29ed17	Cyber Security	cyber-security-security-defence-emergency-management	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b9b5f472-032f-4c35-9ec4-aecef21301f4	ef8c3004-6633-407a-a524-466abc29ed17	Information Security	information-security-security-defence-emergency-management	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ce04b05b-f335-44c1-8aab-718985a608cf	ef8c3004-6633-407a-a524-466abc29ed17	Security Studies	security-studies-security-defence-emergency-management	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d045fa08-56ba-4edb-a399-4b1b68945b24	ef8c3004-6633-407a-a524-466abc29ed17	International Security	international-security-security-defence-emergency-management	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5e41039b-af97-437f-ae7a-3527bcab6e59	ef8c3004-6633-407a-a524-466abc29ed17	Defence Studies	defence-studies-security-defence-emergency-management	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a2f417e6-f404-4dfb-b0cf-20526789de6a	ef8c3004-6633-407a-a524-466abc29ed17	Strategic Studies	strategic-studies-security-defence-emergency-management	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
07a6ce9d-f24c-4262-8711-94a85244db4e	ef8c3004-6633-407a-a524-466abc29ed17	Intelligence Studies	intelligence-studies-security-defence-emergency-management	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0918c35d-6116-426e-a317-2593fef9e758	ef8c3004-6633-407a-a524-466abc29ed17	Counterterrorism	counterterrorism	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
81be97c8-1b18-407e-a657-0b23e842d0e2	ef8c3004-6633-407a-a524-466abc29ed17	Emergency Management	emergency-management	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
deabbe35-af2b-4a7d-a19e-897711eb0299	ef8c3004-6633-407a-a524-466abc29ed17	Disaster Management	disaster-management	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
de54b9a5-c071-4e51-a0cc-07e759f99c3f	ef8c3004-6633-407a-a524-466abc29ed17	Crisis Management	crisis-management	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
bf281efc-73c0-4926-86fd-21d39c250488	ef8c3004-6633-407a-a524-466abc29ed17	Risk Management	risk-management-security-defence-emergency-management	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
62d1f6da-fa61-43fa-93cb-93b733775b74	ef8c3004-6633-407a-a524-466abc29ed17	Homeland Security	homeland-security	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b715f174-5bf3-43cb-8d6e-c3645de66284	ef8c3004-6633-407a-a524-466abc29ed17	Aviation Security	aviation-security-security-defence-emergency-management	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b7881cba-01cb-4a0c-bf85-608d67eb0280	ef8c3004-6633-407a-a524-466abc29ed17	Maritime Security	maritime-security	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a0c5624c-2f8d-447e-b745-e9b59b5d9301	ef8c3004-6633-407a-a524-466abc29ed17	Forensic Science	forensic-science-security-defence-emergency-management	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
18a2ef69-0bab-4e36-8c03-71f9f6d582f6	ef8c3004-6633-407a-a524-466abc29ed17	Criminal Justice	criminal-justice-security-defence-emergency-management	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e75f77c7-0ae4-44ac-8a88-0879e7f371a3	ef8c3004-6633-407a-a524-466abc29ed17	Criminology	criminology-security-defence-emergency-management	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2ba39963-954c-4187-8e4b-fb57caac176a	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Artificial Intelligence	artificial-intelligence-emerging-interdisciplinary-subjects	\N	f	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
d3d957a7-c2d2-498a-9f8b-f3743e3e7f30	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Generative AI	generative-ai-emerging-interdisciplinary-subjects	\N	f	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c5d605bd-5bc4-44c8-84b4-88b52026374f	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Machine Learning	machine-learning-emerging-interdisciplinary-subjects	\N	f	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c097e96e-6db7-40b4-a956-bf63d206ba06	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Data Science	data-science-emerging-interdisciplinary-subjects	\N	f	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
79a482e0-1a11-4c16-aec6-7b803fd85604	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Business Analytics	business-analytics-emerging-interdisciplinary-subjects	\N	f	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
eb8eba08-a762-486d-ba3f-51915845fac5	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Digital Transformation	digital-transformation-emerging-interdisciplinary-subjects	\N	f	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f8f9c06d-bc5b-40d4-8301-a05e100c4821	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Digital Innovation	digital-innovation	\N	f	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e8c3140a-4b10-41b5-b036-ae2ac109452b	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	FinTech	fintech-emerging-interdisciplinary-subjects	\N	f	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5aadf17b-3133-4f5b-97f4-d04504121be2	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Health Informatics	health-informatics-emerging-interdisciplinary-subjects	\N	f	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
044ed50a-5712-4208-a0b7-771179f74bc0	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Bioinformatics	bioinformatics-emerging-interdisciplinary-subjects	\N	f	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0fbf6ba1-5778-4d25-afb4-3d8a18d13e5b	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Cyber Security	cyber-security-emerging-interdisciplinary-subjects	\N	f	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e5fbb0fa-1821-47f5-8bcb-d1911f14fcc4	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Blockchain	blockchain-emerging-interdisciplinary-subjects	\N	f	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
bcfb5980-3289-41c7-b1c0-14b069c1023a	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Internet of Things	internet-of-things-emerging-interdisciplinary-subjects	\N	f	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0a95c8f6-69fc-4d3a-bb91-9bbb30f949f4	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Robotics	robotics-emerging-interdisciplinary-subjects	\N	f	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
40eb6819-10ff-426e-a668-054ead6aafb3	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Autonomous Systems	autonomous-systems-emerging-interdisciplinary-subjects	\N	f	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a13b8215-851c-4ae3-837a-6180a29ffe2a	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Quantum Computing	quantum-computing-emerging-interdisciplinary-subjects	\N	f	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
fc166410-0729-4fd7-a08e-76af0c4bf345	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Sustainability	sustainability	\N	f	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2e40fac2-80c4-486a-9a77-34518ccacbed	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Climate Change	climate-change-emerging-interdisciplinary-subjects	\N	f	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
5bdb7c9d-c12b-4918-b43b-b2c116126450	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Renewable Energy	renewable-energy-emerging-interdisciplinary-subjects	\N	f	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
22954d73-15af-48ec-b1bd-57e3d8969d63	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Environmental Sustainability	environmental-sustainability-emerging-interdisciplinary-subjects	\N	f	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
72d8698f-7e68-434e-918a-63141ad4b6da	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Smart Cities	smart-cities	\N	f	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
88de8dd7-204f-4eeb-b989-7b86f9dc51cd	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Urban Technology	urban-technology	\N	f	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
dca8797e-8e4d-4cd5-9f40-a049fece4183	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Digital Humanities	digital-humanities	\N	f	published	23	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e3ddc2f9-ff1b-4041-ab3d-462ea35420da	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Computational Social Science	computational-social-science	\N	f	published	24	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
121b34be-ae3d-4718-a18e-42707621ecdc	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Cognitive Science	cognitive-science-emerging-interdisciplinary-subjects	\N	f	published	25	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a3937f77-9ad8-430f-94d5-0a60596627e1	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Neuroscience	neuroscience-emerging-interdisciplinary-subjects	\N	f	published	26	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f3dfdb09-f5e9-496c-a11f-ee6500dc64f5	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Human-Computer Interaction	human-computer-interaction-emerging-interdisciplinary-subjects	\N	f	published	27	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
67a313ef-56d0-4c5c-9647-0214e0da4eb8	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	UX Design	ux-design-emerging-interdisciplinary-subjects	\N	f	published	28	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
70cc88b1-767e-4d74-9e3b-551b2266ef8e	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Immersive Technologies	immersive-technologies	\N	f	published	29	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
10c46a6d-cc5e-46cc-9ee6-ee5c666b7440	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Virtual Reality	virtual-reality-emerging-interdisciplinary-subjects	\N	f	published	30	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
a06e1b10-6c67-47bd-8b57-94df006c68b4	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Augmented Reality	augmented-reality-emerging-interdisciplinary-subjects	\N	f	published	31	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
9b1914e0-2c9d-48dc-b1e7-4d6fd4bd29c4	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Extended Reality	extended-reality-emerging-interdisciplinary-subjects	\N	f	published	32	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
bd64c3c6-0ccb-49e8-a4bc-c615d4acf9ab	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Space Science	space-science	\N	f	published	33	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0ab2f8c7-26e4-4080-8818-d78d3be7815e	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Space Technology	space-technology	\N	f	published	34	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
e82708d0-7836-40db-ac3b-c1eba6e416b0	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Nanotechnology	nanotechnology-emerging-interdisciplinary-subjects	\N	f	published	35	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
8e6a0c45-bff1-4b05-8423-bfa3d9eeb111	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Materials Science	materials-science-emerging-interdisciplinary-subjects	\N	f	published	36	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
\.


--
-- Data for Name: study_levels; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.study_levels (id, name, slug, description, duration, status, display_order, created_at, updated_at, entry_label, requirements) FROM stdin;
3d06a17a-15b2-4357-8446-9aeb7096b6e7	Foundation	foundation	A preparatory year that builds the subject knowledge and English skills needed to start a bachelor's degree.	1 year	published	1	2026-11-07 06:30:26.963138+00	\N	\N	\N
8a1bd769-f51b-4ef7-bd13-8f4ccf285238	Pathway	pathway	A programme run with a partner university that leads into the first or second year of a degree.	6-12 months	published	2	2026-11-07 06:30:26.963138+00	\N	\N	\N
fb4d1ed5-49dc-4497-8f09-358aef2f6481	Diploma	diploma	Practical, career-focused study that often counts towards the second year of a bachelor's degree.	1-2 years	published	3	2026-11-07 06:30:26.963138+00	\N	\N	\N
25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	Master's	masters	Specialist or career-change study after a bachelor's degree.	1-2 years	published	5	2026-11-07 06:30:26.963138+00	\N	\N	\N
3e60c856-f2be-46a2-8fa9-6b4fe0c2d46d	MBA	mba	A master's degree in business and management, usually for people with work experience.	1-2 years	published	6	2026-11-07 06:30:26.963138+00	\N	\N	\N
64af34f0-7033-4dd2-a580-36c0e776b4ea	PhD	phd	Original research under a supervisor, usually after a master's degree.	3-5 years	published	7	2026-11-07 06:30:26.963138+00	\N	\N	\N
9537c93a-8eb2-4066-9e6f-ad1e4b17512f	Bachelor's	bachelors	<p>Your first university degree, after finishing secondary school <strong>this is updated</strong> .</p>	3-4 years	published	4	2026-11-07 06:30:26.963138+00	2026-11-09 03:13:04.909+00	\N	\N
6a18853c-07ce-47c2-a0a5-a5c4d1a3d2da	PGDM	pg	<p><strong class="rQesXe MPyX" data-sfc-cp="" data-sfc-root="c" data-complete="true"><span data-subtree="aimfl,mfl">PGDM</span><!--TgQPHd|||[]--></strong> <em><strong>stands </strong></em>for <strong class="rQesXe MPyX" data-sfc-cp="" data-sfc-root="c" data-complete="true">Post Graduate Diploma in Management<!--TgQPHd|||[]--></strong>. It is <mark class="b6AQX" data-wiz-attrbind="class=cqWbw_o/cFwyDc" data-sfc-root="c" data-ved="2ahUKEwjFirTT0_qXAxWumuEIHQI_D54QuJAPegoIAggACAAIBRAB" data-complete="true">a <strong class="rQesXe MPyX" data-sfc-cp="" data-sfc-root="c" data-complete="true">two-year, master's-level business management program<!--TgQPHd|||[]--></strong> offered by autonomous institutes approved by the All India Council for Technical Education (AICTE), rather than traditional universities</mark></p>	2-years	published	7	2026-11-09 04:07:03.239+00	2026-11-09 10:17:40.704+00	Masters	\N
\.


--
-- Data for Name: subject_sections; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.subject_sections (id, subject_id, section, title, subtitle, body, url, is_sponsored, status, display_order, created_at, updated_at, study_level_id, specialization_id) FROM stdin;
785ce42b-9556-4b25-a5fb-10c24b7f744f	969d467c-ab12-44d9-ba02-dd9cf1726d5e	course	Sample Course	Bachelor's	<p>Sample course description.</p>	\N	f	published	1	2026-11-09 19:49:48.941668+00	\N	\N	\N
c9216789-d615-4a09-9c7f-a444c280afa7	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	company	Sample Company Ltd	\N	<p>Sample company description.</p>	https://example.com	t	published	1	2026-11-09 19:49:48.941668+00	\N	\N	\N
41b37bf7-b31c-469c-ae90-a474419a94ae	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	course	Sample Course	Bachelor's	<p>Sample course description.</p>	\N	f	published	1	2026-11-09 19:49:48.941668+00	\N	\N	\N
469848ac-c459-4e01-a7ec-3e02a6b28ea7	969d467c-ab12-44d9-ba02-dd9cf1726d5e	why	Why study Arts, Humanities & Social Sciences?	\N	<p>Sample text: this subject opens doors to <strong>global careers</strong>, strong salaries and study options in many countries.</p>	\N	f	published	1	2026-11-09 19:49:48.941668+00	\N	\N	\N
13e344f6-eeae-42c3-a81d-88e7d17ae9a6	969d467c-ab12-44d9-ba02-dd9cf1726d5e	industry	Healthcare	\N	<p>Sample industry description.</p>	\N	f	published	2	2026-11-09 19:49:48.941668+00	\N	\N	\N
cb1c3693-af52-4c49-b984-1d66e5c2df79	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	industry	Healthcare	\N	<p>Sample industry description.</p>	\N	f	published	2	2026-11-09 19:49:48.941668+00	\N	\N	\N
0a70c15f-847b-41d4-9553-f2f753ca7671	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	destination	United Kingdom	\N	<p>Sample destination description.</p>	\N	f	published	1	2026-11-09 19:49:48.941668+00	\N	\N	\N
21bbf202-dddc-438f-8996-489eed730f91	969d467c-ab12-44d9-ba02-dd9cf1726d5e	university	Sample University	London	<p>Sample university description.</p>	https://example.com	f	published	1	2026-11-09 19:49:48.941668+00	\N	\N	\N
d9d7c56c-dbdb-4772-80c3-efaafd8655f2	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	industry	Technology	\N	<p>Sample industry description.</p>	\N	f	published	1	2026-11-09 19:49:48.941668+00	\N	\N	\N
008870ca-91ff-4c06-8756-f97367a8609d	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	university	Sample University	London	<p>Sample university description.</p>	https://example.com	f	published	1	2026-11-09 19:49:48.941668+00	\N	\N	\N
82d36cf5-e48d-4316-802b-15c62e97fde0	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	university	Sample University	London	<p>Sample university description.</p>	https://example.com	f	published	1	2026-11-09 19:49:48.941668+00	\N	\N	\N
c33e9391-d2b4-4889-b0b5-21316ca4ccd6	969d467c-ab12-44d9-ba02-dd9cf1726d5e	destination	United Kingdom	\N	<p>Sample destination description.</p>	\N	f	published	1	2026-11-09 19:49:48.941668+00	\N	\N	\N
6a3b475d-d1b6-4717-945d-882dd564e0fa	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	industry	Technology	\N	<p>Sample industry description.</p>	\N	f	published	1	2026-11-09 19:49:48.941668+00	\N	\N	\N
df09e383-4e66-4115-8317-e8b594bbefb9	969d467c-ab12-44d9-ba02-dd9cf1726d5e	industry	Technology	\N	<p>Sample industry description.</p>	\N	f	published	1	2026-11-09 19:49:48.941668+00	\N	\N	\N
1f10015f-46dd-4ac3-8042-e35ff7ab1479	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	destination	United Kingdom	\N	<p>Sample destination description.</p>	\N	f	published	1	2026-11-09 19:49:48.941668+00	\N	\N	\N
270518da-33f8-4c95-b80f-319c027b9527	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	industry	Healthcare	\N	<p>Sample industry description.</p>	\N	f	published	2	2026-11-09 19:49:48.941668+00	\N	\N	\N
74a7cc3d-aad5-4b3f-b743-cbcfc11f322b	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	course	Sample Course	Bachelor's	<p>Sample course description.</p>	\N	f	published	1	2026-11-09 19:49:48.941668+00	\N	\N	\N
c431522c-a918-4bfe-abae-6716695a2435	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	why	Why study Agriculture & Environmental Sciences?	\N	<p>Sample text: this subject opens doors to <strong>global careers</strong>, strong salaries and study options in many countries.</p>	\N	f	published	1	2026-11-09 19:49:48.941668+00	\N	\N	\N
17579a44-c3ab-4ccd-b8bb-922c29d891f3	969d467c-ab12-44d9-ba02-dd9cf1726d5e	company	Sample Company Ltd	\N	<p>Sample company description.</p>	https://example.com	t	published	1	2026-11-09 19:49:48.941668+00	\N	\N	\N
a0df687b-0cd1-4ae5-b3d7-7f3d2412877e	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	company	Sample Company Ltd	\N	<p>Sample company description.</p>	https://example.com	t	published	1	2026-11-09 19:49:48.941668+00	\N	\N	\N
4ee5582d-591c-4001-b632-ea1d9a0fc654	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	why	Why study Architecture & Built Environment?	\N	<p>Architecture and the built environment deal with how places are imagined, designed, delivered and looked after over time. The field brings together creative disciplines such as <a href="https://applicationabroad.com/subjects/architecture-built-environment/architecture/">Architecture</a>, <a href="https://applicationabroad.com/subjects/architecture-built-environment/interior-architecture/">Interior Architecture</a> and <a href="https://applicationabroad.com/subjects/architecture-built-environment/landscape-architecture/">Landscape Architecture</a> with technical and commercial ones such as <a href="https://applicationabroad.com/subjects/architecture-built-environment/construction-management/">Construction Management</a>, <a href="https://applicationabroad.com/subjects/architecture-built-environment/quantity-surveying/">Quantity Surveying</a> and <a href="https://applicationabroad.com/subjects/architecture-built-environment/real-estate/">Real Estate</a>.</p>\n<p>Students learn to work across scales, from the detail of a building junction to the layout of a neighbourhood. Design studios sit alongside structures, building services, materials, law, cost and planning policy, so every proposal is tested against how it will be built, used and paid for. <a href="https://applicationabroad.com/subjects/architecture-built-environment/urban-planning/">Urban Planning</a> and <a href="https://applicationabroad.com/subjects/architecture-built-environment/heritage-conservation/">Heritage Conservation</a> extend the same thinking to cities and historic places.</p>\n<p>The subject suits people who enjoy drawing and problem-solving as much as organising people and information. Building codes, climates and planning systems differ between countries, so studying abroad can offer a useful comparative view. Some programmes are linked to professional accreditation, which is worth checking for the country where you plan to work.</p>	\N	f	published	1	2026-11-09 19:49:48.941668+00	2026-11-09 20:26:26.105+00	\N	\N
7de890d6-77a8-409c-9fd1-69375aa8d6e2	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	about	About Foundation in Architecture & Built Environment	\N	<p>Sample text: what a {level} in this field looks like.</p>	\N	f	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
dc4c985f-9ab2-49df-8a4b-f7e3e3350967	969d467c-ab12-44d9-ba02-dd9cf1726d5e	about	About Foundation in Arts, Humanities & Social Sciences	\N	<p>Sample text: what a {level} in this field looks like.</p>	\N	f	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
dead43b5-a3b5-4c6f-b8c1-d354662d2a93	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	why	Why choose a Foundation in Agriculture & Environmental Sciences?	\N	<p>Sample text: reasons to study at this level.</p>	\N	f	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
6970b225-da0c-498a-af5f-88f48139deff	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	why	Why choose a Foundation in Architecture & Built Environment?	\N	<p>Sample text: reasons to study at this level.</p>	\N	f	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
5b6f379d-dedb-4fad-8128-f3c4c1bc4572	969d467c-ab12-44d9-ba02-dd9cf1726d5e	why	Why choose a Foundation in Arts, Humanities & Social Sciences?	\N	<p>Sample text: reasons to study at this level.</p>	\N	f	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
8dc54b45-4ba0-4688-a38b-1a23b0111515	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	industry	Technology	\N	<p>Sample industry for this level.</p>	\N	f	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
f880bf4b-374e-4d9f-9030-910a0b2aa7c3	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	industry	Technology	\N	<p>Sample industry for this level.</p>	\N	f	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
e90c9b81-4dab-409e-acf3-54352a7edf00	969d467c-ab12-44d9-ba02-dd9cf1726d5e	industry	Technology	\N	<p>Sample industry for this level.</p>	\N	f	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
f1176d12-ac2f-4803-86b4-196c960b8659	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	company	Sample Company Ltd	\N	<p>Sample company that hires at this level.</p>	https://example.com	t	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
1fb80bf5-a53f-49fd-9481-ed63f4cac300	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	company	Sample Company Ltd	\N	<p>Sample company that hires at this level.</p>	https://example.com	t	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
3077a102-2c37-4a3c-8628-1a24977eea2d	969d467c-ab12-44d9-ba02-dd9cf1726d5e	company	Sample Company Ltd	\N	<p>Sample company that hires at this level.</p>	https://example.com	t	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
9a7fb749-2c2a-4982-9ff2-226b571b3dc1	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	advertisement	Sample advertisement	\N	<p>Sample sponsored message.</p>	https://example.com	t	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
1264c12c-37f3-4715-8723-f7703b178bab	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	advertisement	Sample advertisement	\N	<p>Sample sponsored message.</p>	https://example.com	t	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
97014858-3bcd-4d4a-ace2-c14f4e5968bf	969d467c-ab12-44d9-ba02-dd9cf1726d5e	advertisement	Sample advertisement	\N	<p>Sample sponsored message.</p>	https://example.com	t	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
cd233e55-6cc8-44be-8202-b0b0f23fc5b2	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	about	About Foundation in Agriculture & Environmental Sciences	\N	<p>hit this is my new content&nbsp;</p>	\N	f	published	1	2026-11-09 20:35:23.636025+00	2026-11-10 08:58:46.735+00	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
cba8991d-fa53-4834-a152-95a0fcee5a1a	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	cta	Get free advice on your Foundation	\N	<p>Sample call to action text.</p>	\N	f	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
ca0ac065-6927-47ed-86b5-486e79b904e9	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	cta	Get free advice on your Foundation	\N	<p>Sample call to action text.</p>	\N	f	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
5b00c399-9ec9-4817-abba-53b0ff2d5043	969d467c-ab12-44d9-ba02-dd9cf1726d5e	cta	Get free advice on your Foundation	\N	<p>Sample call to action text.</p>	\N	f	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
6c7dac45-c76a-40db-a378-0b0424a66993	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	course	Sample Course	Sample University	<p>Sample course.</p>	https://example.com	t	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
17512e80-3a7e-4937-a379-65137041fe58	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	course	Sample Course	Sample University	<p>Sample course.</p>	https://example.com	t	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
f88e3c94-ca8a-44c3-853e-24191bb9e42e	969d467c-ab12-44d9-ba02-dd9cf1726d5e	course	Sample Course	Sample University	<p>Sample course.</p>	https://example.com	t	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
3f666445-5398-47c9-b0b7-a96db423cff3	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	destination	United Kingdom	\N	<p>Sample destination.</p>	\N	f	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
6b8f8da9-175e-4326-b5d5-19b5f76469bc	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	destination	United Kingdom	\N	<p>Sample destination.</p>	\N	f	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
438a0549-d642-4910-a640-23026f8704cf	969d467c-ab12-44d9-ba02-dd9cf1726d5e	destination	United Kingdom	\N	<p>Sample destination.</p>	\N	f	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
326a3984-27c5-4745-8196-c91554268e03	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	university	Sample University	London	<p>Sample university.</p>	https://example.com	t	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
c8888000-3a67-4843-9250-9610286fb899	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	university	Sample University	London	<p>Sample university.</p>	https://example.com	t	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
3b2fa9bd-a42f-4ee0-97b0-640ba8494da1	969d467c-ab12-44d9-ba02-dd9cf1726d5e	university	Sample University	London	<p>Sample university.</p>	https://example.com	t	published	1	2026-11-09 20:35:23.636025+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	\N
44deb987-60a3-4d31-a5ee-60e6b8cb06ff	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	why	Bachelors	\N	<p><span data-subtree="aimfl,mfl">A bachelor's degree </span><mark class="b6AQX" data-wiz-attrbind="class=JVJwCd_o/cFwyDc" data-sfc-root="c" data-ved="2ahUKEwi6guKX4PuXAxUcT2wGHcElPLcQuJAPegoIAggACAAICRAB" data-complete="true">unlocks a wider range of career opportunities, higher earning potential, and faster professional advancement compared to a high school diploma.</mark></p>	\N	f	published	0	2026-11-09 20:46:15.74+00	\N	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	\N
7136e0fe-5783-43da-a72b-6b657cc7c276	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	about	About Agribusiness	\N	<p>Sample text: what {spec} is about.</p>	\N	f	published	1	2026-11-09 20:52:28.106129+00	\N	\N	c6505fa6-068e-489d-9294-6e7c861e4d14
616b8cc6-b4ef-403a-90e2-a8d037e36d5f	969d467c-ab12-44d9-ba02-dd9cf1726d5e	about	About Humanities	\N	<p>Sample text: what {spec} is about.</p>	\N	f	published	1	2026-11-09 20:52:28.106129+00	\N	\N	99c634f2-f660-410e-b11f-5950dc6ffea5
6536e4af-063e-46a8-9e50-13214f158fcf	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	why	Why study Agribusiness?	\N	<p>Sample text: reasons to choose {spec}.</p>	\N	f	published	1	2026-11-09 20:52:28.106129+00	\N	\N	c6505fa6-068e-489d-9294-6e7c861e4d14
1e5eaf1b-010d-4834-a149-ea3f2ed9ff51	969d467c-ab12-44d9-ba02-dd9cf1726d5e	why	Why study Humanities?	\N	<p>Sample text: reasons to choose {spec}.</p>	\N	f	published	1	2026-11-09 20:52:28.106129+00	\N	\N	99c634f2-f660-410e-b11f-5950dc6ffea5
78dbe3bf-aee0-4ea3-b6fc-500100bcb340	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	industry	Technology	\N	<p>Sample industry.</p>	\N	f	published	1	2026-11-09 20:52:28.106129+00	\N	\N	c6505fa6-068e-489d-9294-6e7c861e4d14
7f2701d2-8fa3-4fdc-8c40-0ed720c93d8f	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	industry	Technology	\N	<p>Sample industry.</p>	\N	f	published	1	2026-11-09 20:52:28.106129+00	\N	\N	b910a05a-0e32-4648-ac1e-1407af3c89fb
3d54a8ef-20d6-4b5d-9690-61b47339e09f	969d467c-ab12-44d9-ba02-dd9cf1726d5e	industry	Technology	\N	<p>Sample industry.</p>	\N	f	published	1	2026-11-09 20:52:28.106129+00	\N	\N	99c634f2-f660-410e-b11f-5950dc6ffea5
2194807a-bd5d-4158-980a-bb4a1aaf4c35	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	company	Sample Company Ltd	\N	<p>Sample company.</p>	https://example.com	t	published	1	2026-11-09 20:52:28.106129+00	\N	\N	c6505fa6-068e-489d-9294-6e7c861e4d14
e24f79f3-18bd-4f88-8713-6221a6bce79e	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	company	Sample Company Ltd	\N	<p>Sample company.</p>	https://example.com	t	published	1	2026-11-09 20:52:28.106129+00	\N	\N	b910a05a-0e32-4648-ac1e-1407af3c89fb
fe2748bb-ad7a-41b4-9192-9277d49ac1e9	969d467c-ab12-44d9-ba02-dd9cf1726d5e	company	Sample Company Ltd	\N	<p>Sample company.</p>	https://example.com	t	published	1	2026-11-09 20:52:28.106129+00	\N	\N	99c634f2-f660-410e-b11f-5950dc6ffea5
b9b45964-2e1d-47cc-9e87-205618fc0052	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	advertisement	Sample advertisement	\N	<p>Sample sponsored message.</p>	https://example.com	t	published	1	2026-11-09 20:52:28.106129+00	\N	\N	c6505fa6-068e-489d-9294-6e7c861e4d14
1dc924ce-453b-442a-86ca-16f4378f7dcb	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	advertisement	Sample advertisement	\N	<p>Sample sponsored message.</p>	https://example.com	t	published	1	2026-11-09 20:52:28.106129+00	\N	\N	b910a05a-0e32-4648-ac1e-1407af3c89fb
7a72bf8d-58e0-4539-abb5-9934a1cf3117	969d467c-ab12-44d9-ba02-dd9cf1726d5e	advertisement	Sample advertisement	\N	<p>Sample sponsored message.</p>	https://example.com	t	published	1	2026-11-09 20:52:28.106129+00	\N	\N	99c634f2-f660-410e-b11f-5950dc6ffea5
8273a7d5-3c62-4321-beff-f4e7148d5d1d	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	cta	Get free advice on Agribusiness	\N	<p>Sample call to action text.</p>	\N	f	published	1	2026-11-09 20:52:28.106129+00	\N	\N	c6505fa6-068e-489d-9294-6e7c861e4d14
8674b92b-c17e-4b68-9b97-cb91000e47c4	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	cta	Get free advice on Architecture	\N	<p>Sample call to action text.</p>	\N	f	published	1	2026-11-09 20:52:28.106129+00	\N	\N	b910a05a-0e32-4648-ac1e-1407af3c89fb
e6a04fbb-fd94-49f8-90e9-b3570fa68173	969d467c-ab12-44d9-ba02-dd9cf1726d5e	cta	Get free advice on Humanities	\N	<p>Sample call to action text.</p>	\N	f	published	1	2026-11-09 20:52:28.106129+00	\N	\N	99c634f2-f660-410e-b11f-5950dc6ffea5
40a22fa7-cc22-43d0-a205-688975172986	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	course	Sample Course	Sample University	<p>Sample course.</p>	https://example.com	t	published	1	2026-11-09 20:52:28.106129+00	\N	\N	c6505fa6-068e-489d-9294-6e7c861e4d14
310c53c8-305e-4c30-97c6-ed04ff0b2824	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	course	Sample Course	Sample University	<p>Sample course.</p>	https://example.com	t	published	1	2026-11-09 20:52:28.106129+00	\N	\N	b910a05a-0e32-4648-ac1e-1407af3c89fb
6bc5b63b-812e-47b8-8003-1d57ae6e5bf3	969d467c-ab12-44d9-ba02-dd9cf1726d5e	course	Sample Course	Sample University	<p>Sample course.</p>	https://example.com	t	published	1	2026-11-09 20:52:28.106129+00	\N	\N	99c634f2-f660-410e-b11f-5950dc6ffea5
42c21cc5-51d2-4ede-ae6c-2b0a85be203d	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	destination	United Kingdom	\N	<p>Sample destination.</p>	\N	f	published	1	2026-11-09 20:52:28.106129+00	\N	\N	c6505fa6-068e-489d-9294-6e7c861e4d14
fcc6578e-c282-4b80-ba28-ab605fccd160	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	destination	United Kingdom	\N	<p>Sample destination.</p>	\N	f	published	1	2026-11-09 20:52:28.106129+00	\N	\N	b910a05a-0e32-4648-ac1e-1407af3c89fb
f14dbedd-098f-4e8c-8b8d-c819f08ff827	969d467c-ab12-44d9-ba02-dd9cf1726d5e	destination	United Kingdom	\N	<p>Sample destination.</p>	\N	f	published	1	2026-11-09 20:52:28.106129+00	\N	\N	99c634f2-f660-410e-b11f-5950dc6ffea5
30f815e2-5b8d-4740-b25b-421ad5499455	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	university	Sample University	London	<p>Sample university.</p>	https://example.com	t	published	1	2026-11-09 20:52:28.106129+00	\N	\N	c6505fa6-068e-489d-9294-6e7c861e4d14
67bda8fa-59bc-4f37-9dbb-9a3ec56f07a6	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	university	Sample University	London	<p>Sample university.</p>	https://example.com	t	published	1	2026-11-09 20:52:28.106129+00	\N	\N	b910a05a-0e32-4648-ac1e-1407af3c89fb
4cae7dbb-d5c1-4c95-bb90-665e42210b9d	969d467c-ab12-44d9-ba02-dd9cf1726d5e	university	Sample University	London	<p>Sample university.</p>	https://example.com	t	published	1	2026-11-09 20:52:28.106129+00	\N	\N	99c634f2-f660-410e-b11f-5950dc6ffea5
ab2f0545-8945-48e0-a1f0-4a798339ff64	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	about	About Architecture	\N	<p><span data-subtree="aimfl,mfl"><strong>Architecture </strong>is </span><mark class="b6AQX" data-wiz-attrbind="class=NT2wub_5f/cFwyDc" data-sfc-root="c" data-ved="2ahUKEwji-J30yPyXAxVPTWwGHaoCDZYQuJAPegoIAggACAAIDBAB">the art and science of designing, planning, and constructing buildings and physical structures<!--TgQPHd|||[[[null,null,null,null,null,null,null,null,null,null,null,null,[247864,null,0]]]]--></mark>. It sits at the intersection of creative expression and structural engineering, shaping how people live, work, and interact with their environments</p>	\N	f	published	1	2026-11-09 20:52:28.106129+00	2026-11-10 04:32:56.806+00	\N	b910a05a-0e32-4648-ac1e-1407af3c89fb
f104f072-fe15-4570-87aa-e2966b96686c	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	why	Why study Architecture?	\N	<p><strong class="rQesXe MPyX" data-sfc-cp="" data-sfc-root="c" data-complete="true" data-processed="true"><span data-subtree="aimfl" data-processed="true">Architecture is the profound intersection of creative expression, technical innovation, and human experience.</span><!--TgQPHd|||[]--></strong> It is the art and science of shaping the physical environments that define how we live, work, connect, and evolve. To study architecture is to become a visionary problem solver, transforming complex spatial challenges into sustainable, beautiful, and highly functional realities. By blending design thinking with historical context and structural engineering, architects do not just build structures&mdash;they design the future, leaving a tangible, lasting legacy on communities and the natural world.</p>	\N	f	published	1	2026-11-09 20:52:28.106129+00	2026-11-10 04:35:09.405+00	\N	b910a05a-0e32-4648-ac1e-1407af3c89fb
5b2c9e91-51db-4160-a630-3e81c3fa4f13	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	about	About Foundation in Agribusiness	\N	<p>Sample text: what a {level} in {spec} looks like.</p>	\N	f	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	c6505fa6-068e-489d-9294-6e7c861e4d14
19917111-3173-439e-bd35-6ee9db9bce74	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	about	About Foundation in Architecture	\N	<p>Sample text: what a {level} in {spec} looks like.</p>	\N	f	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	b910a05a-0e32-4648-ac1e-1407af3c89fb
9f066437-6c78-428f-b93d-78812ba2d5ed	969d467c-ab12-44d9-ba02-dd9cf1726d5e	about	About Foundation in Humanities	\N	<p>Sample text: what a {level} in {spec} looks like.</p>	\N	f	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	99c634f2-f660-410e-b11f-5950dc6ffea5
eeb588c1-6aab-430a-ae77-3d0301d408bb	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	why	Why choose a Foundation in Agribusiness?	\N	<p>Sample text: reasons to choose this path.</p>	\N	f	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	c6505fa6-068e-489d-9294-6e7c861e4d14
c0f5dcc9-6f69-4379-b800-7c21953626b9	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	why	Why choose a Foundation in Architecture?	\N	<p>Sample text: reasons to choose this path.</p>	\N	f	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	b910a05a-0e32-4648-ac1e-1407af3c89fb
a2821a0d-b394-4099-8b08-7c2451629d9b	969d467c-ab12-44d9-ba02-dd9cf1726d5e	why	Why choose a Foundation in Humanities?	\N	<p>Sample text: reasons to choose this path.</p>	\N	f	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	99c634f2-f660-410e-b11f-5950dc6ffea5
dd0baae8-3b2a-41c4-84ec-d960ca4fc50e	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	industry	Technology	\N	<p>Sample industry.</p>	\N	f	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	c6505fa6-068e-489d-9294-6e7c861e4d14
5774a11f-3f1d-4040-b39e-2a7094c4a03c	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	industry	Technology	\N	<p>Sample industry.</p>	\N	f	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	b910a05a-0e32-4648-ac1e-1407af3c89fb
70c05c14-81ae-427f-85f9-3f463a8d5af2	969d467c-ab12-44d9-ba02-dd9cf1726d5e	industry	Technology	\N	<p>Sample industry.</p>	\N	f	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	99c634f2-f660-410e-b11f-5950dc6ffea5
508e90b7-0d92-4ec9-b804-5d290aaa4bb9	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	company	Sample Company Ltd	\N	<p>Sample company.</p>	https://example.com	t	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	c6505fa6-068e-489d-9294-6e7c861e4d14
f6da32be-86f5-4b11-832b-76acd8454913	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	company	Sample Company Ltd	\N	<p>Sample company.</p>	https://example.com	t	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	b910a05a-0e32-4648-ac1e-1407af3c89fb
da39cbc0-4ac1-4718-9daf-b7ae5bd47893	969d467c-ab12-44d9-ba02-dd9cf1726d5e	company	Sample Company Ltd	\N	<p>Sample company.</p>	https://example.com	t	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	99c634f2-f660-410e-b11f-5950dc6ffea5
e9fe79de-2141-4cc3-a8bf-7e1507c167f2	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	advertisement	Sample advertisement	\N	<p>Sample sponsored message.</p>	https://example.com	t	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	c6505fa6-068e-489d-9294-6e7c861e4d14
453af035-9e25-4f2b-9325-398955e9cfdb	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	advertisement	Sample advertisement	\N	<p>Sample sponsored message.</p>	https://example.com	t	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	b910a05a-0e32-4648-ac1e-1407af3c89fb
04613fef-965c-4ccd-8245-6a5e839fb9d7	969d467c-ab12-44d9-ba02-dd9cf1726d5e	advertisement	Sample advertisement	\N	<p>Sample sponsored message.</p>	https://example.com	t	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	99c634f2-f660-410e-b11f-5950dc6ffea5
fed4521a-5064-4223-bdf9-b9582346660f	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	cta	Get free advice on Agribusiness	\N	<p>Sample call to action text.</p>	\N	f	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	c6505fa6-068e-489d-9294-6e7c861e4d14
d5f114f0-6795-4124-96c8-ebc3ee63d1b8	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	cta	Get free advice on Architecture	\N	<p>Sample call to action text.</p>	\N	f	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	b910a05a-0e32-4648-ac1e-1407af3c89fb
7478ca26-076a-4fe4-a367-fc89d2d835d1	969d467c-ab12-44d9-ba02-dd9cf1726d5e	cta	Get free advice on Humanities	\N	<p>Sample call to action text.</p>	\N	f	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	99c634f2-f660-410e-b11f-5950dc6ffea5
736782e7-bebe-42bb-bdd2-b54691294b36	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	course	Sample Course	Sample University	<p>Sample course.</p>	https://example.com	t	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	c6505fa6-068e-489d-9294-6e7c861e4d14
fd0b255b-489a-4a9d-b672-7c2ecf589d74	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	course	Sample Course	Sample University	<p>Sample course.</p>	https://example.com	t	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	b910a05a-0e32-4648-ac1e-1407af3c89fb
3c7a4bf9-1406-44e6-b3d1-d4bdc276baf6	969d467c-ab12-44d9-ba02-dd9cf1726d5e	course	Sample Course	Sample University	<p>Sample course.</p>	https://example.com	t	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	99c634f2-f660-410e-b11f-5950dc6ffea5
090d2c62-b335-4d9e-95cf-cc4ac4770855	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	destination	United Kingdom	\N	<p>Sample destination.</p>	\N	f	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	c6505fa6-068e-489d-9294-6e7c861e4d14
a3cb2385-58e6-4114-a5d3-3a009bde5869	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	destination	United Kingdom	\N	<p>Sample destination.</p>	\N	f	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	b910a05a-0e32-4648-ac1e-1407af3c89fb
870b2833-3045-4b4a-bc64-ab5d89f6c991	969d467c-ab12-44d9-ba02-dd9cf1726d5e	destination	United Kingdom	\N	<p>Sample destination.</p>	\N	f	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	99c634f2-f660-410e-b11f-5950dc6ffea5
69fbf2a7-03e2-4171-b02d-ee9d5d3904ec	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	university	Sample University	London	<p>Sample university.</p>	https://example.com	t	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	c6505fa6-068e-489d-9294-6e7c861e4d14
9858ac2d-e5f0-4dc5-87bc-b4feae99dd62	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	university	Sample University	London	<p>Sample university.</p>	https://example.com	t	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	b910a05a-0e32-4648-ac1e-1407af3c89fb
b3d8ed6e-1be4-4263-82e0-d9ed2802975d	969d467c-ab12-44d9-ba02-dd9cf1726d5e	university	Sample University	London	<p>Sample university.</p>	https://example.com	t	published	1	2026-11-10 05:07:49.6838+00	\N	3d06a17a-15b2-4357-8446-9aeb7096b6e7	99c634f2-f660-410e-b11f-5950dc6ffea5
\.


--
-- Data for Name: subject_study_levels; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.subject_study_levels (id, subject_id, study_level_id, created_at) FROM stdin;
21a90c85-f10b-49af-a8f2-01520d67f6af	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
1d108848-b5cf-43c9-9896-2359bfaecf8c	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
6a93108f-8827-4903-a8a8-743945f75234	969d467c-ab12-44d9-ba02-dd9cf1726d5e	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
2fd6dd6d-6b0d-43b5-873d-35cf0764b291	6217a93d-16b1-48b1-9206-4b3589dcd87b	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
73686931-2242-4ff2-86e7-669e8346a1fb	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
688d75ea-0982-4c58-ae28-17c8e6be43fa	7ef86a94-d348-4493-8cdd-5d8b45e1a158	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
ab53292a-d840-45f8-ae64-b4e30ccf750d	2fade289-afaf-4576-a339-973446b73868	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
32213abd-9e28-4fa4-a76f-da2dd094b6cf	80c9db7a-2c88-41a8-b848-5499ed9cf439	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
8e140008-4857-49ad-8f25-01f8bfb9da1c	cf60d367-8dda-47c9-b15c-a0e6bb456c32	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
a74676bd-4203-41d4-b2e5-fd5ce25b2372	29d0e951-5d39-453f-9590-22c15d1b49d0	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
af5aee34-c3b5-4129-9064-75cfdde3dd57	c819c508-8ab3-4141-bfbb-60638764d637	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
e220ff12-76c5-4071-a151-fd0124205343	923cc411-0a83-4ced-97a8-4485c695b3af	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
83238bd9-453a-4601-8e29-36ab762654ad	1fc4061b-cb36-4a3f-8463-3cd114d7b659	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
c633c92e-b9a2-4134-a859-508d2e752db2	03300472-f68e-431d-a79f-4ac3cf81019f	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
d3236ce9-cfe1-4bca-bb19-f33cfd76d43a	88de387b-7974-4c1e-80cc-9cfe95fd660a	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
f87ba82f-db8c-401c-b397-d34d557514b0	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
259f6eb8-d895-408c-bf4b-7441306b9706	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
e7ad6558-68b8-401c-bb32-7718db43424d	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
a5966f7e-c1d3-497c-aa7b-7afa8ac4dbaf	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
5895311d-51d1-4b31-906f-0879f96b15ee	0104cd86-3a4b-4efb-9146-cb45541c0e64	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
02da94c3-e456-4f0c-bde5-303d5a3799f7	bd852326-e555-450e-82c2-bef3f76b6e92	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
e5363044-add4-474d-9077-fa5041e5fd57	16ac725d-d1b0-48b0-927f-6c3743de8ba0	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
f55c86cd-acdb-4dca-aa0b-52de893536f1	90b7c9bd-2e27-4cd0-ba71-0739f269a104	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
f63911f5-018f-40b0-ba97-cad4b66e3116	7879f520-178b-4aa5-b6f7-c8db7486ca6b	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
87ddbf33-b1fd-424e-ad8d-fc487ed3ad38	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
97f2b574-b5d1-4d00-a9b5-837287bc428d	7985d638-c390-420e-a594-befe81db9621	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
a3a697c1-985e-4a72-8cd6-1f1321f839e3	7f6682ba-7ae6-439b-a99e-af8135f9995f	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
7301ad30-fa66-470f-8228-35a04cd05e8b	b887195b-f5fd-4a21-b1dd-35f5e689323b	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
997a4790-c0fd-4a20-b1cc-b6ab1263b59b	ef8c3004-6633-407a-a524-466abc29ed17	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
077299f5-9284-408f-a785-be53ab0380ef	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	3d06a17a-15b2-4357-8446-9aeb7096b6e7	2026-11-07 06:30:27.002057+00
822d2faa-0015-43a9-9c1f-13c42d514f88	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
426fd87d-b946-4c3d-9319-97aeaf750256	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
eb497a21-365a-4cb2-8b55-100fea55c01d	969d467c-ab12-44d9-ba02-dd9cf1726d5e	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
473ba669-8a12-4420-86ae-681d092ed319	6217a93d-16b1-48b1-9206-4b3589dcd87b	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
6ebdc8d5-2d1b-4b1c-9403-aed77ade6ed2	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
be491dc0-c2ed-40da-ada1-7bf69a571da1	7ef86a94-d348-4493-8cdd-5d8b45e1a158	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
6bae8572-f2ca-4df0-ad04-4b1e5906f179	2fade289-afaf-4576-a339-973446b73868	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
ff0aef84-7661-4a2c-afb0-96127d1433db	80c9db7a-2c88-41a8-b848-5499ed9cf439	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
dd182c49-06c6-4862-b996-9b80f18349f2	cf60d367-8dda-47c9-b15c-a0e6bb456c32	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
908b83b8-8739-43f6-baf1-beaf373c4438	29d0e951-5d39-453f-9590-22c15d1b49d0	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
168c5f5d-ffae-4d88-b77c-ae3a67c8dc98	c819c508-8ab3-4141-bfbb-60638764d637	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
0b083999-a6c1-4046-a20a-2aab91a03a4f	923cc411-0a83-4ced-97a8-4485c695b3af	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
470796c6-8c25-423a-94d9-1dc7a2f8f8dd	1fc4061b-cb36-4a3f-8463-3cd114d7b659	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
087f2e2a-6477-421e-8545-0b04cc25bfd9	03300472-f68e-431d-a79f-4ac3cf81019f	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
86800fb5-6daf-4f8c-9602-60dbb2fcb71a	88de387b-7974-4c1e-80cc-9cfe95fd660a	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
78fd286d-d518-44ee-a219-64841f7abf7a	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
a3a453fe-fed1-4f46-b9e7-a5a4dc2a50ff	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
bd5c7826-f5ff-477f-97a9-78a3e1ecd49d	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
03a5c07d-29e1-4179-ab31-ff3a9abfe717	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
c15fa999-1d70-459c-95ff-6d9ca150cda0	0104cd86-3a4b-4efb-9146-cb45541c0e64	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
8e80ea20-8364-4222-a4ea-c9e395209ab8	bd852326-e555-450e-82c2-bef3f76b6e92	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
1a5ee4ae-0ae3-4baf-ac0e-fcfe0322ad2e	16ac725d-d1b0-48b0-927f-6c3743de8ba0	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
fd384f3c-6aa8-4847-85f9-bdd405899ea8	90b7c9bd-2e27-4cd0-ba71-0739f269a104	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
def96226-5037-4ff4-9802-a1e10b0529cb	7879f520-178b-4aa5-b6f7-c8db7486ca6b	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
4a215d93-5a92-4b8c-9f19-a01961193529	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
444f8ad7-ed43-40be-bda3-e4e92b095569	7985d638-c390-420e-a594-befe81db9621	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
f888ddfa-d002-4b9e-9f5b-d6c1456b0ea3	7f6682ba-7ae6-439b-a99e-af8135f9995f	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
22d4cc2b-6f9a-4d64-b407-b4c36a47c709	b887195b-f5fd-4a21-b1dd-35f5e689323b	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
a4db789d-1a48-413d-9f32-d811e6cdfe7b	ef8c3004-6633-407a-a524-466abc29ed17	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
7ba7ee5c-8b74-48b1-a577-3c2d75b932db	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	8a1bd769-f51b-4ef7-bd13-8f4ccf285238	2026-11-07 06:30:27.002057+00
2b9b9fe0-ed5c-421c-83b6-219afc049ffc	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
ce4ee373-85dd-4b5a-88ac-be390c1d1319	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
a68f55e8-e33c-43e3-b3c1-0e3cdbc00ac2	969d467c-ab12-44d9-ba02-dd9cf1726d5e	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
56e4545d-5f6f-4e83-bcb0-ba55c2a83320	6217a93d-16b1-48b1-9206-4b3589dcd87b	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
90f573ec-6475-48b6-b68f-82c5330e59fd	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
b69bf78e-b61b-4b1c-b151-f106eb899b07	7ef86a94-d348-4493-8cdd-5d8b45e1a158	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
e1f17eda-4bfe-42be-b104-373a6c283fe5	2fade289-afaf-4576-a339-973446b73868	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
df7e1f8a-cd7b-4d47-a353-0f58e6b60fec	80c9db7a-2c88-41a8-b848-5499ed9cf439	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
af640db1-640c-4cad-a7de-dbab0b436ed8	cf60d367-8dda-47c9-b15c-a0e6bb456c32	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
11b73dcd-25e6-4d0a-a44a-e90a8f2a73e2	29d0e951-5d39-453f-9590-22c15d1b49d0	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
507dbb69-5fc1-4f48-867b-e90c1fb81429	c819c508-8ab3-4141-bfbb-60638764d637	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
ecf909e7-ecd3-42e8-8594-2cc8904a5eeb	923cc411-0a83-4ced-97a8-4485c695b3af	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
1054502b-9d02-42c8-a1a7-de1ffb5d0a90	1fc4061b-cb36-4a3f-8463-3cd114d7b659	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
b8eac5aa-04db-41f2-a51b-23329cd7dd65	03300472-f68e-431d-a79f-4ac3cf81019f	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
a1f8905e-1cb5-4650-9ddd-583e0c1f0d3d	88de387b-7974-4c1e-80cc-9cfe95fd660a	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
95f7b628-7b00-41eb-8a1b-bac699f44508	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
7ee39310-6796-4b87-a374-f134d430164f	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
749d365c-32a8-4280-9802-09f7b7323361	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
8ad0a324-878c-45f5-b786-64dcce31307f	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
bd4347b8-2b53-49ea-a031-af6ef113b212	0104cd86-3a4b-4efb-9146-cb45541c0e64	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
fcc0fd7e-5411-4b02-aaac-800444616883	bd852326-e555-450e-82c2-bef3f76b6e92	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
35e90d34-4330-4adc-8c9b-46af99e5e3f1	16ac725d-d1b0-48b0-927f-6c3743de8ba0	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
8b75b0fd-a414-41db-ae9c-98b4fd7dcf29	90b7c9bd-2e27-4cd0-ba71-0739f269a104	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
29bd8ccf-0a01-489f-949e-50840ac406cf	7879f520-178b-4aa5-b6f7-c8db7486ca6b	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
2f9dede5-a531-4af6-be7c-8d929cacaa10	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
5d8d1390-3ed7-4d6c-ae64-7b796de21840	7985d638-c390-420e-a594-befe81db9621	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
78d5828c-8611-4e58-bcd6-9c9415cef157	7f6682ba-7ae6-439b-a99e-af8135f9995f	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
4342a2e1-fc7a-4fd1-82c1-3c1241aca58a	b887195b-f5fd-4a21-b1dd-35f5e689323b	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
8a50e676-fb33-4c6b-a5f7-0254ab34b04f	ef8c3004-6633-407a-a524-466abc29ed17	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
77ec8388-e32e-47b6-ae2b-40d83f192fc4	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	fb4d1ed5-49dc-4497-8f09-358aef2f6481	2026-11-07 06:30:27.002057+00
68ca8445-0120-4d42-a606-8923e3c18eb5	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
77f9f9e4-dc59-469b-aa88-a5a08f15fcb5	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
ddf3b9cb-3491-4e86-8e0e-03d04117c69f	969d467c-ab12-44d9-ba02-dd9cf1726d5e	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
5cc6698a-004a-409d-902d-ac7b1b3f3218	6217a93d-16b1-48b1-9206-4b3589dcd87b	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
5aa26208-a20f-4ee7-a7c9-8b99e43f4e55	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
14b0d7fe-481a-42e8-9450-57d11c548135	7ef86a94-d348-4493-8cdd-5d8b45e1a158	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
67b271f4-c99a-473f-8065-79ae7feba914	2fade289-afaf-4576-a339-973446b73868	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
3356a658-56c2-43ce-a824-b62589a50f9b	80c9db7a-2c88-41a8-b848-5499ed9cf439	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
6ad8a52d-7854-4ae0-821a-b1a616e64dcb	cf60d367-8dda-47c9-b15c-a0e6bb456c32	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
57617fd7-6b20-423c-b324-470e08d48e70	29d0e951-5d39-453f-9590-22c15d1b49d0	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
1b99f09b-91de-41c8-b450-ca7c03877493	c819c508-8ab3-4141-bfbb-60638764d637	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
abb7ad06-6620-4c4b-8cf3-416e1e5d0558	923cc411-0a83-4ced-97a8-4485c695b3af	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
99a06dad-d497-4d47-8a8c-5d37194cd201	1fc4061b-cb36-4a3f-8463-3cd114d7b659	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
6aed2a10-bda4-4309-8f96-2d54598aa191	03300472-f68e-431d-a79f-4ac3cf81019f	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
e078a6ad-e529-4cfa-b40b-044e8f68a095	88de387b-7974-4c1e-80cc-9cfe95fd660a	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
c1e07fae-9a96-483d-b6aa-62743919869d	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
5e51aa97-d63f-41cb-b098-d01fda1279cc	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
afcff5f9-aa19-46d5-86a7-698b994e0ded	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
c0717000-ff3e-4444-a03f-0110e34fd6ef	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
898b9d2d-4294-4d99-945d-b07944a63357	0104cd86-3a4b-4efb-9146-cb45541c0e64	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
d96fbef0-8cb3-40b4-8649-edbbc4781025	bd852326-e555-450e-82c2-bef3f76b6e92	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
6b871441-37ee-4d7d-98f0-99bed7e4b3d6	16ac725d-d1b0-48b0-927f-6c3743de8ba0	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
76161498-cc02-4990-af26-2f6750530eec	90b7c9bd-2e27-4cd0-ba71-0739f269a104	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
3d710e2f-70d2-4bfe-b1f8-1e03106969a6	7879f520-178b-4aa5-b6f7-c8db7486ca6b	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
9207bbe4-0d85-40f9-ad69-3641f8dc4318	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
88a17a1f-c831-4219-a446-2f252a81466a	7985d638-c390-420e-a594-befe81db9621	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
5ee33d05-8b02-428c-9169-a160ced59cca	7f6682ba-7ae6-439b-a99e-af8135f9995f	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
d16263e3-3902-4b08-82d1-6c21dda76822	b887195b-f5fd-4a21-b1dd-35f5e689323b	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
dcb57d91-a8bf-4091-9169-f82ccc06a5c0	ef8c3004-6633-407a-a524-466abc29ed17	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
33339bf8-961b-499e-a378-30597030c54b	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	9537c93a-8eb2-4066-9e6f-ad1e4b17512f	2026-11-07 06:30:27.002057+00
cd5690bd-08d6-44dc-91a0-6d66c1bef96e	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
6f3aaf45-8713-4842-8909-5d6f078d92f1	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
22347d54-07ed-4709-a8bd-2a8822393792	969d467c-ab12-44d9-ba02-dd9cf1726d5e	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
f4aa1cfc-af0f-4828-9e0b-8a7fba38f8e5	6217a93d-16b1-48b1-9206-4b3589dcd87b	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
3217d87a-f38c-4123-ba48-b4c879b029aa	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
9adc0031-09d9-417a-bf9f-2148fcd613dd	7ef86a94-d348-4493-8cdd-5d8b45e1a158	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
a9974d90-ca9b-4dcb-90f0-953a4e837a65	2fade289-afaf-4576-a339-973446b73868	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
a90f0175-2539-430b-9382-63feeeb7945f	80c9db7a-2c88-41a8-b848-5499ed9cf439	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
19500ef8-bd9e-4460-a040-a798b8a84567	cf60d367-8dda-47c9-b15c-a0e6bb456c32	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
ce973130-0561-46f6-9620-8fa4ee0b50ac	29d0e951-5d39-453f-9590-22c15d1b49d0	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
518d5af1-233c-4da5-901f-fc1491cdd503	c819c508-8ab3-4141-bfbb-60638764d637	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
a1e6c985-b6e2-4ac7-9d46-9f4b3c15f066	923cc411-0a83-4ced-97a8-4485c695b3af	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
7d1b7ef0-1412-454e-aa26-e7dda2509fcf	1fc4061b-cb36-4a3f-8463-3cd114d7b659	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
4320ccd8-8fc3-41da-a68d-b2c37f848053	03300472-f68e-431d-a79f-4ac3cf81019f	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
71676a76-6eb8-4784-8412-3920b765370f	88de387b-7974-4c1e-80cc-9cfe95fd660a	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
7e75e701-f0ab-432a-a4f4-15e39819c4c7	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
fcdf2f64-ad57-4daa-a0a9-4087ac02faeb	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
8d2f1df3-404e-4496-8802-e96ce6995cef	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
8e34a7d2-10e9-4626-8e67-f62750d480fe	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
e89c223e-b41d-4f92-bdd4-9c9ffdfabd20	0104cd86-3a4b-4efb-9146-cb45541c0e64	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
5ecaf92f-b587-4e8d-a3d5-5235333eaf22	bd852326-e555-450e-82c2-bef3f76b6e92	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
81a73903-8baf-449a-8466-923ee6da5b4e	16ac725d-d1b0-48b0-927f-6c3743de8ba0	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
ed24cdcc-440e-4cde-acc8-1efa4a920014	90b7c9bd-2e27-4cd0-ba71-0739f269a104	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
68a4c6ac-7039-440d-9595-4ac8ab2a9a26	7879f520-178b-4aa5-b6f7-c8db7486ca6b	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
24d0c2c8-963d-4cc7-9f49-8dd1dbc8b8c3	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
3e9aac72-5b7d-4fdf-936c-a3a947b51b44	7985d638-c390-420e-a594-befe81db9621	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
2c0e202f-212f-49fd-830b-fc313b6ae5a9	7f6682ba-7ae6-439b-a99e-af8135f9995f	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
7257f4db-bcfe-4ba9-ab58-867f47b2bf45	b887195b-f5fd-4a21-b1dd-35f5e689323b	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
efde90e3-2cc3-49b1-a720-086dea1ff2c4	ef8c3004-6633-407a-a524-466abc29ed17	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
3aa555e8-de56-4e0b-8d8a-75cb8311c3be	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	25b4d685-9c2b-4f99-aadf-a2f4a5510bd5	2026-11-07 06:30:27.002057+00
a78fbf82-8147-4e9c-a715-4e57e2ad9fcc	6217a93d-16b1-48b1-9206-4b3589dcd87b	3e60c856-f2be-46a2-8fa9-6b4fe0c2d46d	2026-11-07 06:30:27.002057+00
f4cef88c-e712-46f3-a500-156d6784ffc3	7486c9a7-2cda-4b0d-85c9-1581b3ce1548	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
307e1452-4fbd-46f5-bbdf-2251946a8e18	f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
8cffb43d-826b-4c6e-a68e-277cc5d768be	969d467c-ab12-44d9-ba02-dd9cf1726d5e	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
2ef072f7-7ccd-48b6-a3e6-e2c64e788f99	6217a93d-16b1-48b1-9206-4b3589dcd87b	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
fc57a47e-500f-47d1-a707-7a4ae018c935	6d1d1b53-4ee7-4363-bb15-747ef36bdf08	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
cf75d157-675c-4dbb-b19b-277aba4c05e0	7ef86a94-d348-4493-8cdd-5d8b45e1a158	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
c48c4ce2-e58d-4065-b54b-925b108fca24	2fade289-afaf-4576-a339-973446b73868	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
b1f07f37-728f-4cc0-9d7a-ccd283db779a	80c9db7a-2c88-41a8-b848-5499ed9cf439	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
9cfe5211-4ac1-4546-9aaf-386531eda534	cf60d367-8dda-47c9-b15c-a0e6bb456c32	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
5a51be16-f818-41c2-8a7f-112f7610bb01	29d0e951-5d39-453f-9590-22c15d1b49d0	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
5ed2891a-97af-43dd-8357-3929f2d9b6a9	c819c508-8ab3-4141-bfbb-60638764d637	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
cfcf6497-465a-4ffe-8043-d255ef455d6f	923cc411-0a83-4ced-97a8-4485c695b3af	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
4c17c540-5f4d-4ad5-a40f-7cdc237c8b50	1fc4061b-cb36-4a3f-8463-3cd114d7b659	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
f2a93f36-4c04-4510-9126-a615b2826d10	03300472-f68e-431d-a79f-4ac3cf81019f	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
bb90012d-4bf1-49de-ab39-a30fb8a20f34	88de387b-7974-4c1e-80cc-9cfe95fd660a	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
65cb0afa-f358-48fa-bc92-1339581b9af6	3ba532e2-0a0c-4a8a-8eed-0abdb985710e	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
88dd8975-8503-435e-86b3-c0cd730a3f83	82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
a2fb1fd1-9de7-4747-a929-37d4bbcb159f	3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
cc759d30-5dbc-4d86-af6b-90db11776235	0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
73f95e59-9a4e-4189-9bd6-0f5427d585af	0104cd86-3a4b-4efb-9146-cb45541c0e64	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
d0a928d7-362c-4d93-a17d-d502b4bc9774	bd852326-e555-450e-82c2-bef3f76b6e92	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
19120f9e-493a-4187-98b4-4096abd51640	16ac725d-d1b0-48b0-927f-6c3743de8ba0	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
73c57f9e-37de-4f5c-b7cc-8cf867dd0db7	90b7c9bd-2e27-4cd0-ba71-0739f269a104	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
4b877089-17ba-4257-aba4-416a4368ee9f	7879f520-178b-4aa5-b6f7-c8db7486ca6b	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
d3fa3001-65af-4f09-8f13-a90a265cc3bd	0b91bdfd-dcf8-44e2-8810-158e45b8abd8	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
8ddb295f-a548-4038-937b-2d600514f53d	7985d638-c390-420e-a594-befe81db9621	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
f40304f9-5e2b-4db9-95e8-db0204ceda5f	7f6682ba-7ae6-439b-a99e-af8135f9995f	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
baf9f03b-4367-4db3-9291-15ea38daf40a	b887195b-f5fd-4a21-b1dd-35f5e689323b	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
9915ca75-582f-4d76-a012-44970e1f17d7	ef8c3004-6633-407a-a524-466abc29ed17	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
20403be0-df2c-4e85-8e8e-6b8c08534c1f	6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	64af34f0-7033-4dd2-a580-36c0e776b4ea	2026-11-07 06:30:27.002057+00
\.


--
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: abroad
--

COPY public.subjects (id, name, slug, description, icon_key, status, display_order, created_by, updated_by, reviewed_by, created_at, updated_at, published_at) FROM stdin;
7486c9a7-2cda-4b0d-85c9-1581b3ce1548	Agriculture & Environmental Sciences	agriculture-environmental-sciences	\N	\N	published	1	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
f5c09fe6-9fbd-4c8d-8f4e-53e2049e34aa	Architecture & Built Environment	architecture-built-environment	\N	pen-tool	published	2	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
969d467c-ab12-44d9-ba02-dd9cf1726d5e	Arts, Humanities & Social Sciences	arts-humanities-social-sciences	\N	users	published	3	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6217a93d-16b1-48b1-9206-4b3589dcd87b	Business & Management	business-management	\N	briefcase	published	4	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6d1d1b53-4ee7-4363-bb15-747ef36bdf08	Computing & Information Technology	computing-information-technology	\N	code	published	5	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7ef86a94-d348-4493-8cdd-5d8b45e1a158	Education, PGCE & Teaching	education-pgce-teaching	\N	\N	published	6	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
2fade289-afaf-4576-a339-973446b73868	Engineering	engineering	\N	cog	published	7	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
80c9db7a-2c88-41a8-b848-5499ed9cf439	Science	science	\N	flask	published	8	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
cf60d367-8dda-47c9-b15c-a0e6bb456c32	Creative Arts, Design & Communication	creative-arts-design-communication	\N	pen-tool	published	9	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
29d0e951-5d39-453f-9590-22c15d1b49d0	Communication, Media & Journalism	communication-media-journalism	\N	megaphone	published	10	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
c819c508-8ab3-4141-bfbb-60638764d637	Health, Medicine & Veterinary Studies	health-medicine-veterinary-studies	\N	heart	published	11	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
923cc411-0a83-4ced-97a8-4485c695b3af	Law	law	\N	scale	published	12	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
1fc4061b-cb36-4a3f-8463-3cd114d7b659	Hospitality, Tourism & Events	hospitality-tourism-events	\N	utensils	published	13	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
03300472-f68e-431d-a79f-4ac3cf81019f	Sports & Exercise	sports-exercise	\N	\N	published	14	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
88de387b-7974-4c1e-80cc-9cfe95fd660a	Psychology & Behavioural Sciences	psychology-behavioural-sciences	\N	users	published	15	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3ba532e2-0a0c-4a8a-8eed-0abdb985710e	Fashion & Textiles	fashion-textiles	\N	pen-tool	published	16	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
82fd0e1e-1f58-4ff4-a1a4-6888bf7ab220	Hospitality, Culinary & Food	hospitality-culinary-food	\N	utensils	published	17	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
3f9d1cda-0a4d-45f3-b7ab-05fc420dc9d2	Aviation & Aerospace	aviation-aerospace	\N	\N	published	18	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0dfb5bc6-a999-4bcc-8681-4fc02e4b3f57	Maritime & Shipping	maritime-shipping	\N	\N	published	19	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0104cd86-3a4b-4efb-9146-cb45541c0e64	Media, Entertainment & Gaming	media-entertainment-gaming	\N	megaphone	published	20	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
bd852326-e555-450e-82c2-bef3f76b6e92	Public Policy, Government & International Studies	public-policy-government-international-studies	\N	\N	published	21	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
16ac725d-d1b0-48b0-927f-6c3743de8ba0	Economics & Finance	economics-finance	\N	briefcase	published	22	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
90b7c9bd-2e27-4cd0-ba71-0739f269a104	Mathematics & Statistics	mathematics-statistics	\N	\N	published	23	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7879f520-178b-4aa5-b6f7-c8db7486ca6b	Biological & Life Sciences	biological-life-sciences	\N	flask	published	24	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
0b91bdfd-dcf8-44e2-8810-158e45b8abd8	Pharmaceutical & Pharmaceutical Sciences	pharmaceutical-pharmaceutical-sciences	\N	flask	published	25	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7985d638-c390-420e-a594-befe81db9621	Social Work & Community Services	social-work-community-services	\N	users	published	26	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
7f6682ba-7ae6-439b-a99e-af8135f9995f	Transport & Logistics	transport-logistics	\N	\N	published	27	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
b887195b-f5fd-4a21-b1dd-35f5e689323b	Energy, Oil & Gas	energy-oil-gas	\N	\N	published	28	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
ef8c3004-6633-407a-a524-466abc29ed17	Security, Defence & Emergency Management	security-defence-emergency-management	\N	\N	published	29	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
6b8edc1b-d705-441d-a5ce-e0e4974a9ef1	Emerging & Interdisciplinary Subjects	emerging-interdisciplinary-subjects	\N	\N	published	30	\N	\N	\N	2026-11-07 05:48:26.53524+00	\N	2026-11-07 05:48:26.53524+00
449ded41-2db3-4675-b49d-7e0feb87206f	xyz	x-yz	<p>hi hello&nbsp;</p>	\N	published	31	6a46be53-0fda-4049-ac99-592e43454225	\N	6a46be53-0fda-4049-ac99-592e43454225	2026-11-07 08:08:41.588+00	\N	\N
\.


--
-- Name: directus_activity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: abroad
--

SELECT pg_catalog.setval('public.directus_activity_id_seq', 185, true);


--
-- Name: directus_fields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: abroad
--

SELECT pg_catalog.setval('public.directus_fields_id_seq', 121, true);


--
-- Name: directus_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: abroad
--

SELECT pg_catalog.setval('public.directus_notifications_id_seq', 1, false);


--
-- Name: directus_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: abroad
--

SELECT pg_catalog.setval('public.directus_permissions_id_seq', 1, false);


--
-- Name: directus_presets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: abroad
--

SELECT pg_catalog.setval('public.directus_presets_id_seq', 5, true);


--
-- Name: directus_relations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: abroad
--

SELECT pg_catalog.setval('public.directus_relations_id_seq', 10, true);


--
-- Name: directus_revisions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: abroad
--

SELECT pg_catalog.setval('public.directus_revisions_id_seq', 179, true);


--
-- Name: directus_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: abroad
--

SELECT pg_catalog.setval('public.directus_settings_id_seq', 1, true);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: countries countries_slug_key; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_slug_key UNIQUE (slug);


--
-- Name: directus_access directus_access_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_access
    ADD CONSTRAINT directus_access_pkey PRIMARY KEY (id);


--
-- Name: directus_activity directus_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_activity
    ADD CONSTRAINT directus_activity_pkey PRIMARY KEY (id);


--
-- Name: directus_collections directus_collections_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_collections
    ADD CONSTRAINT directus_collections_pkey PRIMARY KEY (collection);


--
-- Name: directus_comments directus_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_comments
    ADD CONSTRAINT directus_comments_pkey PRIMARY KEY (id);


--
-- Name: directus_dashboards directus_dashboards_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_dashboards
    ADD CONSTRAINT directus_dashboards_pkey PRIMARY KEY (id);


--
-- Name: directus_deployment_projects directus_deployment_projects_deployment_external_id_unique; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_deployment_projects
    ADD CONSTRAINT directus_deployment_projects_deployment_external_id_unique UNIQUE (deployment, external_id);


--
-- Name: directus_deployment_projects directus_deployment_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_deployment_projects
    ADD CONSTRAINT directus_deployment_projects_pkey PRIMARY KEY (id);


--
-- Name: directus_deployment_runs directus_deployment_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_deployment_runs
    ADD CONSTRAINT directus_deployment_runs_pkey PRIMARY KEY (id);


--
-- Name: directus_deployments directus_deployments_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_deployments
    ADD CONSTRAINT directus_deployments_pkey PRIMARY KEY (id);


--
-- Name: directus_deployments directus_deployments_provider_unique; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_deployments
    ADD CONSTRAINT directus_deployments_provider_unique UNIQUE (provider);


--
-- Name: directus_extensions directus_extensions_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_extensions
    ADD CONSTRAINT directus_extensions_pkey PRIMARY KEY (id);


--
-- Name: directus_fields directus_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_fields
    ADD CONSTRAINT directus_fields_pkey PRIMARY KEY (id);


--
-- Name: directus_files directus_files_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_files
    ADD CONSTRAINT directus_files_pkey PRIMARY KEY (id);


--
-- Name: directus_flows directus_flows_operation_unique; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_flows
    ADD CONSTRAINT directus_flows_operation_unique UNIQUE (operation);


--
-- Name: directus_flows directus_flows_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_flows
    ADD CONSTRAINT directus_flows_pkey PRIMARY KEY (id);


--
-- Name: directus_folders directus_folders_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_folders
    ADD CONSTRAINT directus_folders_pkey PRIMARY KEY (id);


--
-- Name: directus_migrations directus_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_migrations
    ADD CONSTRAINT directus_migrations_pkey PRIMARY KEY (version);


--
-- Name: directus_notifications directus_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_notifications
    ADD CONSTRAINT directus_notifications_pkey PRIMARY KEY (id);


--
-- Name: directus_operations directus_operations_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_pkey PRIMARY KEY (id);


--
-- Name: directus_operations directus_operations_reject_unique; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_reject_unique UNIQUE (reject);


--
-- Name: directus_operations directus_operations_resolve_unique; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_resolve_unique UNIQUE (resolve);


--
-- Name: directus_panels directus_panels_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_panels
    ADD CONSTRAINT directus_panels_pkey PRIMARY KEY (id);


--
-- Name: directus_permissions directus_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_permissions
    ADD CONSTRAINT directus_permissions_pkey PRIMARY KEY (id);


--
-- Name: directus_policies directus_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_policies
    ADD CONSTRAINT directus_policies_pkey PRIMARY KEY (id);


--
-- Name: directus_presets directus_presets_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_presets
    ADD CONSTRAINT directus_presets_pkey PRIMARY KEY (id);


--
-- Name: directus_relations directus_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_relations
    ADD CONSTRAINT directus_relations_pkey PRIMARY KEY (id);


--
-- Name: directus_revisions directus_revisions_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_revisions
    ADD CONSTRAINT directus_revisions_pkey PRIMARY KEY (id);


--
-- Name: directus_roles directus_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_roles
    ADD CONSTRAINT directus_roles_pkey PRIMARY KEY (id);


--
-- Name: directus_sessions directus_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_sessions
    ADD CONSTRAINT directus_sessions_pkey PRIMARY KEY (token);


--
-- Name: directus_settings directus_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_pkey PRIMARY KEY (id);


--
-- Name: directus_shares directus_shares_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_shares
    ADD CONSTRAINT directus_shares_pkey PRIMARY KEY (id);


--
-- Name: directus_translations directus_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_translations
    ADD CONSTRAINT directus_translations_pkey PRIMARY KEY (id);


--
-- Name: directus_users directus_users_email_unique; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_email_unique UNIQUE (email);


--
-- Name: directus_users directus_users_external_identifier_unique; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_external_identifier_unique UNIQUE (external_identifier);


--
-- Name: directus_users directus_users_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_pkey PRIMARY KEY (id);


--
-- Name: directus_users directus_users_token_unique; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_token_unique UNIQUE (token);


--
-- Name: directus_versions directus_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_versions
    ADD CONSTRAINT directus_versions_pkey PRIMARY KEY (id);


--
-- Name: enquiries enquiries_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.enquiries
    ADD CONSTRAINT enquiries_pkey PRIMARY KEY (id);


--
-- Name: page_content page_content_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.page_content
    ADD CONSTRAINT page_content_pkey PRIMARY KEY (id);


--
-- Name: popular_searches popular_searches_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.popular_searches
    ADD CONSTRAINT popular_searches_pkey PRIMARY KEY (id);


--
-- Name: specializations specializations_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.specializations
    ADD CONSTRAINT specializations_pkey PRIMARY KEY (id);


--
-- Name: specializations specializations_slug_key; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.specializations
    ADD CONSTRAINT specializations_slug_key UNIQUE (slug);


--
-- Name: study_levels study_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.study_levels
    ADD CONSTRAINT study_levels_pkey PRIMARY KEY (id);


--
-- Name: study_levels study_levels_slug_key; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.study_levels
    ADD CONSTRAINT study_levels_slug_key UNIQUE (slug);


--
-- Name: subject_sections subject_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.subject_sections
    ADD CONSTRAINT subject_sections_pkey PRIMARY KEY (id);


--
-- Name: subject_study_levels subject_study_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.subject_study_levels
    ADD CONSTRAINT subject_study_levels_pkey PRIMARY KEY (id);


--
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: subjects subjects_slug_key; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_slug_key UNIQUE (slug);


--
-- Name: page_content uq_page_section_content; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.page_content
    ADD CONSTRAINT uq_page_section_content UNIQUE (page_key, section_key, content_key);


--
-- Name: subject_study_levels uq_subject_study_level; Type: CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.subject_study_levels
    ADD CONSTRAINT uq_subject_study_level UNIQUE (subject_id, study_level_id);


--
-- Name: directus_activity_timestamp_index; Type: INDEX; Schema: public; Owner: abroad
--

CREATE INDEX directus_activity_timestamp_index ON public.directus_activity USING btree ("timestamp");


--
-- Name: directus_revisions_activity_index; Type: INDEX; Schema: public; Owner: abroad
--

CREATE INDEX directus_revisions_activity_index ON public.directus_revisions USING btree (activity);


--
-- Name: directus_revisions_parent_index; Type: INDEX; Schema: public; Owner: abroad
--

CREATE INDEX directus_revisions_parent_index ON public.directus_revisions USING btree (parent);


--
-- Name: ix_countries_status_display_order; Type: INDEX; Schema: public; Owner: abroad
--

CREATE INDEX ix_countries_status_display_order ON public.countries USING btree (status, display_order);


--
-- Name: ix_enquiries_assigned_to; Type: INDEX; Schema: public; Owner: abroad
--

CREATE INDEX ix_enquiries_assigned_to ON public.enquiries USING btree (assigned_to);


--
-- Name: ix_enquiries_status_created_at; Type: INDEX; Schema: public; Owner: abroad
--

CREATE INDEX ix_enquiries_status_created_at ON public.enquiries USING btree (status, created_at);


--
-- Name: ix_popular_searches_active_order; Type: INDEX; Schema: public; Owner: abroad
--

CREATE INDEX ix_popular_searches_active_order ON public.popular_searches USING btree (is_active, display_order);


--
-- Name: ix_specializations_subject_status_order; Type: INDEX; Schema: public; Owner: abroad
--

CREATE INDEX ix_specializations_subject_status_order ON public.specializations USING btree (subject_id, status, display_order);


--
-- Name: ix_study_levels_status_display_order; Type: INDEX; Schema: public; Owner: abroad
--

CREATE INDEX ix_study_levels_status_display_order ON public.study_levels USING btree (status, display_order);


--
-- Name: ix_subject_sections_subject_section_status_order; Type: INDEX; Schema: public; Owner: abroad
--

CREATE INDEX ix_subject_sections_subject_section_status_order ON public.subject_sections USING btree (subject_id, study_level_id, section, status, display_order);


--
-- Name: ix_subjects_status_display_order; Type: INDEX; Schema: public; Owner: abroad
--

CREATE INDEX ix_subjects_status_display_order ON public.subjects USING btree (status, display_order);


--
-- Name: countries trg_countries_set_slug; Type: TRIGGER; Schema: public; Owner: abroad
--

CREATE TRIGGER trg_countries_set_slug BEFORE INSERT OR UPDATE ON public.countries FOR EACH ROW EXECUTE FUNCTION public.set_slug_from_name();


--
-- Name: specializations trg_specializations_set_slug; Type: TRIGGER; Schema: public; Owner: abroad
--

CREATE TRIGGER trg_specializations_set_slug BEFORE INSERT OR UPDATE ON public.specializations FOR EACH ROW EXECUTE FUNCTION public.set_slug_from_name();


--
-- Name: study_levels trg_study_levels_set_slug; Type: TRIGGER; Schema: public; Owner: abroad
--

CREATE TRIGGER trg_study_levels_set_slug BEFORE INSERT OR UPDATE ON public.study_levels FOR EACH ROW EXECUTE FUNCTION public.set_slug_from_name();


--
-- Name: subjects trg_subjects_set_slug; Type: TRIGGER; Schema: public; Owner: abroad
--

CREATE TRIGGER trg_subjects_set_slug BEFORE INSERT OR UPDATE ON public.subjects FOR EACH ROW EXECUTE FUNCTION public.set_slug_from_name();


--
-- Name: directus_access directus_access_policy_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_access
    ADD CONSTRAINT directus_access_policy_foreign FOREIGN KEY (policy) REFERENCES public.directus_policies(id) ON DELETE CASCADE;


--
-- Name: directus_access directus_access_role_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_access
    ADD CONSTRAINT directus_access_role_foreign FOREIGN KEY (role) REFERENCES public.directus_roles(id) ON DELETE CASCADE;


--
-- Name: directus_access directus_access_user_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_access
    ADD CONSTRAINT directus_access_user_foreign FOREIGN KEY ("user") REFERENCES public.directus_users(id) ON DELETE CASCADE;


--
-- Name: directus_collections directus_collections_group_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_collections
    ADD CONSTRAINT directus_collections_group_foreign FOREIGN KEY ("group") REFERENCES public.directus_collections(collection);


--
-- Name: directus_comments directus_comments_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_comments
    ADD CONSTRAINT directus_comments_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_comments directus_comments_user_updated_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_comments
    ADD CONSTRAINT directus_comments_user_updated_foreign FOREIGN KEY (user_updated) REFERENCES public.directus_users(id);


--
-- Name: directus_dashboards directus_dashboards_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_dashboards
    ADD CONSTRAINT directus_dashboards_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_deployment_projects directus_deployment_projects_deployment_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_deployment_projects
    ADD CONSTRAINT directus_deployment_projects_deployment_foreign FOREIGN KEY (deployment) REFERENCES public.directus_deployments(id) ON DELETE CASCADE;


--
-- Name: directus_deployment_projects directus_deployment_projects_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_deployment_projects
    ADD CONSTRAINT directus_deployment_projects_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_deployment_runs directus_deployment_runs_project_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_deployment_runs
    ADD CONSTRAINT directus_deployment_runs_project_foreign FOREIGN KEY (project) REFERENCES public.directus_deployment_projects(id) ON DELETE CASCADE;


--
-- Name: directus_deployment_runs directus_deployment_runs_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_deployment_runs
    ADD CONSTRAINT directus_deployment_runs_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_deployments directus_deployments_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_deployments
    ADD CONSTRAINT directus_deployments_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_files directus_files_folder_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_files
    ADD CONSTRAINT directus_files_folder_foreign FOREIGN KEY (folder) REFERENCES public.directus_folders(id) ON DELETE SET NULL;


--
-- Name: directus_files directus_files_modified_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_files
    ADD CONSTRAINT directus_files_modified_by_foreign FOREIGN KEY (modified_by) REFERENCES public.directus_users(id);


--
-- Name: directus_files directus_files_uploaded_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_files
    ADD CONSTRAINT directus_files_uploaded_by_foreign FOREIGN KEY (uploaded_by) REFERENCES public.directus_users(id);


--
-- Name: directus_flows directus_flows_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_flows
    ADD CONSTRAINT directus_flows_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_folders directus_folders_parent_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_folders
    ADD CONSTRAINT directus_folders_parent_foreign FOREIGN KEY (parent) REFERENCES public.directus_folders(id);


--
-- Name: directus_notifications directus_notifications_recipient_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_notifications
    ADD CONSTRAINT directus_notifications_recipient_foreign FOREIGN KEY (recipient) REFERENCES public.directus_users(id) ON DELETE CASCADE;


--
-- Name: directus_notifications directus_notifications_sender_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_notifications
    ADD CONSTRAINT directus_notifications_sender_foreign FOREIGN KEY (sender) REFERENCES public.directus_users(id);


--
-- Name: directus_operations directus_operations_flow_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_flow_foreign FOREIGN KEY (flow) REFERENCES public.directus_flows(id) ON DELETE CASCADE;


--
-- Name: directus_operations directus_operations_reject_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_reject_foreign FOREIGN KEY (reject) REFERENCES public.directus_operations(id);


--
-- Name: directus_operations directus_operations_resolve_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_resolve_foreign FOREIGN KEY (resolve) REFERENCES public.directus_operations(id);


--
-- Name: directus_operations directus_operations_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_panels directus_panels_dashboard_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_panels
    ADD CONSTRAINT directus_panels_dashboard_foreign FOREIGN KEY (dashboard) REFERENCES public.directus_dashboards(id) ON DELETE CASCADE;


--
-- Name: directus_panels directus_panels_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_panels
    ADD CONSTRAINT directus_panels_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_permissions directus_permissions_policy_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_permissions
    ADD CONSTRAINT directus_permissions_policy_foreign FOREIGN KEY (policy) REFERENCES public.directus_policies(id) ON DELETE CASCADE;


--
-- Name: directus_presets directus_presets_role_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_presets
    ADD CONSTRAINT directus_presets_role_foreign FOREIGN KEY (role) REFERENCES public.directus_roles(id) ON DELETE CASCADE;


--
-- Name: directus_presets directus_presets_user_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_presets
    ADD CONSTRAINT directus_presets_user_foreign FOREIGN KEY ("user") REFERENCES public.directus_users(id) ON DELETE CASCADE;


--
-- Name: directus_revisions directus_revisions_activity_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_revisions
    ADD CONSTRAINT directus_revisions_activity_foreign FOREIGN KEY (activity) REFERENCES public.directus_activity(id) ON DELETE CASCADE;


--
-- Name: directus_revisions directus_revisions_parent_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_revisions
    ADD CONSTRAINT directus_revisions_parent_foreign FOREIGN KEY (parent) REFERENCES public.directus_revisions(id);


--
-- Name: directus_revisions directus_revisions_version_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_revisions
    ADD CONSTRAINT directus_revisions_version_foreign FOREIGN KEY (version) REFERENCES public.directus_versions(id) ON DELETE CASCADE;


--
-- Name: directus_roles directus_roles_parent_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_roles
    ADD CONSTRAINT directus_roles_parent_foreign FOREIGN KEY (parent) REFERENCES public.directus_roles(id);


--
-- Name: directus_sessions directus_sessions_share_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_sessions
    ADD CONSTRAINT directus_sessions_share_foreign FOREIGN KEY (share) REFERENCES public.directus_shares(id) ON DELETE CASCADE;


--
-- Name: directus_sessions directus_sessions_user_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_sessions
    ADD CONSTRAINT directus_sessions_user_foreign FOREIGN KEY ("user") REFERENCES public.directus_users(id) ON DELETE CASCADE;


--
-- Name: directus_settings directus_settings_project_logo_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_project_logo_foreign FOREIGN KEY (project_logo) REFERENCES public.directus_files(id);


--
-- Name: directus_settings directus_settings_public_background_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_public_background_foreign FOREIGN KEY (public_background) REFERENCES public.directus_files(id);


--
-- Name: directus_settings directus_settings_public_favicon_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_public_favicon_foreign FOREIGN KEY (public_favicon) REFERENCES public.directus_files(id);


--
-- Name: directus_settings directus_settings_public_foreground_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_public_foreground_foreign FOREIGN KEY (public_foreground) REFERENCES public.directus_files(id);


--
-- Name: directus_settings directus_settings_public_registration_role_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_public_registration_role_foreign FOREIGN KEY (public_registration_role) REFERENCES public.directus_roles(id) ON DELETE SET NULL;


--
-- Name: directus_settings directus_settings_storage_default_folder_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_storage_default_folder_foreign FOREIGN KEY (storage_default_folder) REFERENCES public.directus_folders(id) ON DELETE SET NULL;


--
-- Name: directus_shares directus_shares_collection_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_shares
    ADD CONSTRAINT directus_shares_collection_foreign FOREIGN KEY (collection) REFERENCES public.directus_collections(collection) ON DELETE CASCADE;


--
-- Name: directus_shares directus_shares_role_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_shares
    ADD CONSTRAINT directus_shares_role_foreign FOREIGN KEY (role) REFERENCES public.directus_roles(id) ON DELETE CASCADE;


--
-- Name: directus_shares directus_shares_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_shares
    ADD CONSTRAINT directus_shares_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_users directus_users_role_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_role_foreign FOREIGN KEY (role) REFERENCES public.directus_roles(id) ON DELETE SET NULL;


--
-- Name: directus_versions directus_versions_collection_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_versions
    ADD CONSTRAINT directus_versions_collection_foreign FOREIGN KEY (collection) REFERENCES public.directus_collections(collection) ON DELETE CASCADE;


--
-- Name: directus_versions directus_versions_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_versions
    ADD CONSTRAINT directus_versions_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_versions directus_versions_user_updated_foreign; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.directus_versions
    ADD CONSTRAINT directus_versions_user_updated_foreign FOREIGN KEY (user_updated) REFERENCES public.directus_users(id);


--
-- Name: enquiries enquiries_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.enquiries
    ADD CONSTRAINT enquiries_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: enquiries enquiries_preferred_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.enquiries
    ADD CONSTRAINT enquiries_preferred_country_id_fkey FOREIGN KEY (preferred_country_id) REFERENCES public.countries(id) ON DELETE SET NULL;


--
-- Name: subject_sections fk_subject_sections_specialization_id; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.subject_sections
    ADD CONSTRAINT fk_subject_sections_specialization_id FOREIGN KEY (specialization_id) REFERENCES public.specializations(id) ON DELETE CASCADE;


--
-- Name: subject_sections fk_subject_sections_study_level_id; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.subject_sections
    ADD CONSTRAINT fk_subject_sections_study_level_id FOREIGN KEY (study_level_id) REFERENCES public.study_levels(id) ON DELETE CASCADE;


--
-- Name: popular_searches popular_searches_specialization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.popular_searches
    ADD CONSTRAINT popular_searches_specialization_id_fkey FOREIGN KEY (specialization_id) REFERENCES public.specializations(id) ON DELETE CASCADE;


--
-- Name: popular_searches popular_searches_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.popular_searches
    ADD CONSTRAINT popular_searches_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: specializations specializations_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.specializations
    ADD CONSTRAINT specializations_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: specializations specializations_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.specializations
    ADD CONSTRAINT specializations_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: specializations specializations_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.specializations
    ADD CONSTRAINT specializations_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: specializations specializations_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.specializations
    ADD CONSTRAINT specializations_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: subject_sections subject_sections_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.subject_sections
    ADD CONSTRAINT subject_sections_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: subject_study_levels subject_study_levels_study_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.subject_study_levels
    ADD CONSTRAINT subject_study_levels_study_level_id_fkey FOREIGN KEY (study_level_id) REFERENCES public.study_levels(id) ON DELETE CASCADE;


--
-- Name: subject_study_levels subject_study_levels_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.subject_study_levels
    ADD CONSTRAINT subject_study_levels_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: subjects subjects_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: subjects subjects_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: subjects subjects_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: abroad
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict lHUUhxSKlE6pcheRGMS2mg8KDSk96aZGzoKjrW5V1GmpqhaBRf64EpmEemtUrbO

