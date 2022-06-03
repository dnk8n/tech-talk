SET check_function_bodies = false;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE public.channel (
    id uuid NOT NULL,
    name text NOT NULL,
    is_public boolean NOT NULL,
    workspace_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL
);
CREATE TABLE public.channel_member (
    id uuid NOT NULL,
    channel_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.channel_thread (
    id uuid NOT NULL,
    channel_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.channel_thread_message (
    id uuid NOT NULL,
    profile_id uuid NOT NULL,
    channel_thread_id uuid NOT NULL,
    message text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.profiles (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    display_name text,
    bio text,
    phone_number text,
    timezone text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_seen timestamp with time zone,
    password text NOT NULL
);
CREATE VIEW public.online_profiles AS
 SELECT profiles.id,
    profiles.last_seen
   FROM public.profiles
  WHERE (profiles.last_seen >= (now() - '00:00:30'::interval));
CREATE TABLE public.profile_message (
    id uuid NOT NULL,
    profile_id uuid NOT NULL,
    recipient_id uuid NOT NULL,
    message text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    workspace_id uuid NOT NULL
);
CREATE TABLE public.workspace (
    id uuid NOT NULL,
    name text NOT NULL,
    owner_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    url_slug text NOT NULL
);
CREATE TABLE public.workspace_member (
    profile_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    type text DEFAULT 'member'::text NOT NULL
);
CREATE TABLE public.workspace_profile_type (
    type text NOT NULL
);
ALTER TABLE ONLY public.channel_member
    ADD CONSTRAINT channel_member_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.channel_thread_message
    ADD CONSTRAINT channel_thread_message_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.channel_thread
    ADD CONSTRAINT channel_thread_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.channel
    ADD CONSTRAINT channels_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.profile_message
    ADD CONSTRAINT profile_message_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.workspace_profile_type
    ADD CONSTRAINT profile_type_pkey PRIMARY KEY (type);
ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.workspace_member
    ADD CONSTRAINT workspace_members_pkey PRIMARY KEY (profile_id, workspace_id);
ALTER TABLE ONLY public.workspace
    ADD CONSTRAINT workspace_name_key UNIQUE (name);
ALTER TABLE ONLY public.workspace
    ADD CONSTRAINT workspace_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.workspace
    ADD CONSTRAINT workspace_url_slug_key UNIQUE (url_slug);
ALTER TABLE ONLY public.channel_member
    ADD CONSTRAINT channel_member_channel_id_fkey FOREIGN KEY (channel_id) REFERENCES public.channel(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.channel_member
    ADD CONSTRAINT channel_member_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.channel_thread
    ADD CONSTRAINT channel_thread_channel_id_fkey FOREIGN KEY (channel_id) REFERENCES public.channel(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.channel_thread_message
    ADD CONSTRAINT channel_thread_message_channel_thread_id_fkey FOREIGN KEY (channel_thread_id) REFERENCES public.channel_thread(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.channel_thread_message
    ADD CONSTRAINT channel_thread_message_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.channel
    ADD CONSTRAINT channels_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.profile_message
    ADD CONSTRAINT profile_message_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.profiles(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.profile_message
    ADD CONSTRAINT profile_message_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.profile_message
    ADD CONSTRAINT profile_message_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.workspace_member
    ADD CONSTRAINT workspace_member_type_fkey FOREIGN KEY (type) REFERENCES public.workspace_profile_type(type) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.workspace_member
    ADD CONSTRAINT workspace_members_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.workspace_member
    ADD CONSTRAINT workspace_members_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspace(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.workspace
    ADD CONSTRAINT workspace_owner_fkey FOREIGN KEY (owner_id) REFERENCES public.profiles(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
