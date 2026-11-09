create extension if not exists pgcrypto;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '', username text unique,
  avatar_path text, bio text, website text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into public.profiles(id,display_name) values(new.id,coalesce(new.raw_user_meta_data->>'display_name','')); return new; end; $$;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

CREATE TABLE public.posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    body TEXT NOT NULL DEFAULT '',
    media_path TEXT,
    youtube_url TEXT,
    project_title TEXT,
    project_url TEXT,
    is_live BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT posts_content_required
    CHECK (
        length(trim(body)) > 0
        OR media_path IS NOT NULL
        OR youtube_url IS NOT NULL
    )
);
create table public.comments (
  id uuid primary key default gen_random_uuid(), post_id uuid not null references public.posts(id) on delete cascade,
  author_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  body text not null check(length(trim(body))>0), created_at timestamptz not null default now()
);
create table public.post_likes (
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(), primary key(post_id,user_id)
);
create table public.communities (
  id uuid primary key default gen_random_uuid(), name text not null, description text not null default '',
  category text not null default 'General', owner_id uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);
create table public.community_members (
  community_id uuid not null references public.communities(id) on delete cascade,
  user_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  role text not null default 'member', created_at timestamptz not null default now(), primary key(community_id,user_id)
);
create table public.courses (
  id uuid primary key default gen_random_uuid(), title text not null, description text not null default '',
  instructor_id uuid references public.profiles(id) on delete set null, cover_path text,
  youtube_url text, is_published boolean not null default false, created_at timestamptz not null default now()
);
create table public.course_progress (
  course_id uuid not null references public.courses(id) on delete cascade,
  user_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  progress numeric not null default 0 check(progress between 0 and 1), updated_at timestamptz not null default now(), primary key(course_id,user_id)
);
create table public.conversations (id uuid primary key default gen_random_uuid(), created_at timestamptz not null default now());
create table public.conversation_members (
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  user_id uuid not null default auth.uid() references public.profiles(id) on delete cascade, primary key(conversation_id,user_id)
);
create table public.messages (
  id uuid primary key default gen_random_uuid(), conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  body text not null check(length(trim(body))>0), created_at timestamptz not null default now()
);
create table public.friendships (
  user_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  friend_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(), primary key(user_id,friend_id),
  constraint friendships_no_self check(user_id <> friend_id)
);
create table public.activities (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  type text not null, entity_id uuid, payload jsonb not null default '{}',
  created_at timestamptz not null default now()
);
create table public.events (
  id uuid primary key default gen_random_uuid(), title text not null, description text not null default '',
  starts_at timestamptz not null, youtube_url text, host_id uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);
create table public.event_attendees (
  event_id uuid not null references public.events(id) on delete cascade,
  user_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(), primary key(event_id,user_id)
);

alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.comments enable row level security;
alter table public.post_likes enable row level security;
alter table public.communities enable row level security;
alter table public.community_members enable row level security;
alter table public.courses enable row level security;
alter table public.course_progress enable row level security;
alter table public.conversations enable row level security;
alter table public.conversation_members enable row level security;
alter table public.messages enable row level security;
alter table public.friendships enable row level security;
alter table public.activities enable row level security;
alter table public.events enable row level security;
alter table public.event_attendees enable row level security;

create policy "profiles readable" on public.profiles for select to authenticated using(true);
create policy "profile owner manages" on public.profiles for all to authenticated using((select auth.uid())=id) with check((select auth.uid())=id);
create policy "posts readable" on public.posts for select to authenticated using(true);
create policy "author creates posts" on public.posts for insert to authenticated with check((select auth.uid())=author_id);
create policy "author updates posts" on public.posts for update to authenticated using((select auth.uid())=author_id) with check((select auth.uid())=author_id);
create policy "author deletes posts" on public.posts for delete to authenticated using((select auth.uid())=author_id);
create policy "comments readable" on public.comments for select to authenticated using(true);
create policy "comment owner writes" on public.comments for insert to authenticated with check((select auth.uid())=author_id);
create policy "comment owner deletes" on public.comments for delete to authenticated using((select auth.uid())=author_id);
create policy "likes readable" on public.post_likes for select to authenticated using(true);
create policy "user manages own likes" on public.post_likes for all to authenticated using((select auth.uid())=user_id) with check((select auth.uid())=user_id);
create policy "communities readable" on public.communities for select to authenticated using(true);
create policy "members readable" on public.community_members for select to authenticated using(true);
create policy "users manage memberships" on public.community_members for all to authenticated using((select auth.uid())=user_id) with check((select auth.uid())=user_id);
create policy "published courses readable" on public.courses for select to authenticated using(is_published or instructor_id=(select auth.uid()));
create policy "own course progress" on public.course_progress for all to authenticated using((select auth.uid())=user_id) with check((select auth.uid())=user_id);
create policy "conversation members readable" on public.conversations for select to authenticated using(exists(select 1 from public.conversation_members m where m.conversation_id=id and m.user_id=(select auth.uid())));
create policy "members readable" on public.conversation_members for select to authenticated using(exists(select 1 from public.conversation_members m where m.conversation_id=conversation_id and m.user_id=(select auth.uid())));
create policy "messages readable by members" on public.messages for select to authenticated using(exists(select 1 from public.conversation_members m where m.conversation_id=messages.conversation_id and m.user_id=(select auth.uid())));
create policy "members send messages" on public.messages for insert to authenticated with check(sender_id=(select auth.uid()) and exists(select 1 from public.conversation_members m where m.conversation_id=messages.conversation_id and m.user_id=(select auth.uid())));
create policy "community owners manage" on public.communities for all to authenticated using(owner_id=(select auth.uid())) with check(owner_id=(select auth.uid()));
create policy "course instructors manage" on public.courses for all to authenticated using(instructor_id=(select auth.uid())) with check(instructor_id=(select auth.uid()));
create policy "friendship owner manages" on public.friendships for all to authenticated using(user_id=(select auth.uid())) with check(user_id=(select auth.uid()));
create policy "own activity readable" on public.activities for select to authenticated using(user_id=(select auth.uid()));
create policy "own activity writable" on public.activities for insert to authenticated with check(user_id=(select auth.uid()));
create policy "events readable" on public.events for select to authenticated using(true);
create policy "hosts manage events" on public.events for all to authenticated using(host_id=(select auth.uid())) with check(host_id=(select auth.uid()));
create policy "attendees readable" on public.event_attendees for select to authenticated using(true);
create policy "attendee manages own RSVP" on public.event_attendees for all to authenticated using(user_id=(select auth.uid())) with check(user_id=(select auth.uid()));

create or replace function public.is_conversation_member(target_id uuid)
returns boolean language sql stable security definer set search_path=public as $$
  select exists(select 1 from public.conversation_members where conversation_id=target_id and user_id=auth.uid());
$$;
create or replace function public.create_conversation(other_user uuid)
returns uuid language plpgsql security definer set search_path=public as $$
declare new_id uuid;
begin
  if auth.uid() is null or other_user is null or other_user=auth.uid() then raise exception 'Invalid participant'; end if;
  insert into public.conversations default values returning id into new_id;
  insert into public.conversation_members(conversation_id,user_id) values(new_id,auth.uid()),(new_id,other_user);
  return new_id;
end; $$;
grant execute on function public.create_conversation(uuid) to authenticated;

drop policy if exists "conversation members readable" on public.conversations;
drop policy if exists "conversation members readable" on public.conversation_members;
drop policy if exists "conversation members readable" on public.conversations;
create policy "conversation members readable" on public.conversations for select to authenticated using(public.is_conversation_member(id));
drop policy if exists "members readable" on public.conversation_members;
create policy "members readable" on public.conversation_members for select to authenticated using(public.is_conversation_member(conversation_id));

insert into storage.buckets(id,name,public) values ('post-media','post-media',true),('avatars','avatars',true) on conflict(id) do nothing;
create policy "public media read" on storage.objects for select using(bucket_id in ('post-media','avatars'));
create policy "users upload own media" on storage.objects for insert to authenticated with check(bucket_id in ('post-media','avatars') and (storage.foldername(name))[1]=(select auth.uid())::text);
create policy "users update own media" on storage.objects for update to authenticated using((storage.foldername(name))[1]=(select auth.uid())::text) with check((storage.foldername(name))[1]=(select auth.uid())::text);
create policy "users delete own media" on storage.objects for delete to authenticated using((storage.foldername(name))[1]=(select auth.uid())::text);
