-- Add structured project links to posts and allow a project-only post.
alter table public.posts
  add column if not exists project_title text,
  add column if not exists project_url text;

alter table public.posts
  drop constraint if exists posts_content_required;

alter table public.posts
  add constraint posts_content_required
  check (
    length(trim(body)) > 0
    or media_path is not null
    or youtube_url is not null
    or project_url is not null
  );
