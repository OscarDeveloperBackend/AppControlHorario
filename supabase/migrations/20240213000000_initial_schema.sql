-- Create custom types
create type public.rol_usuario as enum ('admin', 'empleado');
create type public.estado_sesion as enum ('activa', 'pausada', 'finalizada');
create type public.tipo_accion as enum ('iniciar', 'pausar', 'reanudar', 'finalizar');

-- Create profiles table
create table public.perfiles (
  id uuid not null references auth.users(id) on delete cascade primary key,
  nombre_completo text,
  rol public.rol_usuario default 'empleado'::public.rol_usuario,
  creado_en timestamp with time zone default now() not null
);

-- Enable RLS for profiles
alter table public.perfiles enable row level security;

-- Create work sessions table
create table public.sesiones_trabajo (
  id uuid default gen_random_uuid() primary key,
  usuario_id uuid not null references public.perfiles(id) on delete cascade,
  hora_inicio timestamp with time zone default now() not null,
  hora_fin timestamp with time zone,
  estado public.estado_sesion default 'activa'::public.estado_sesion not null,
  creado_en timestamp with time zone default now() not null
);

-- Enable RLS for sessions
alter table public.sesiones_trabajo enable row level security;

-- Create action history table
create table public.historial_acciones (
  id uuid default gen_random_uuid() primary key,
  sesion_id uuid not null references public.sesiones_trabajo(id) on delete cascade,
  accion public.tipo_accion not null,
  timestamp timestamp with time zone default now() not null
);

-- Enable RLS for history
alter table public.historial_acciones enable row level security;

-- RLS Policies

-- Profiles: Users can read/edit their own profile
create policy "Users can view own profile"
  on public.perfiles for select
  using ( auth.uid() = id );

create policy "Users can update own profile"
  on public.perfiles for update
  using ( auth.uid() = id );

-- Sessions: Users can CRUD their own sessions
create policy "Users can view own sessions"
  on public.sesiones_trabajo for select
  using ( auth.uid() = usuario_id );

create policy "Users can insert own sessions"
  on public.sesiones_trabajo for insert
  with check ( auth.uid() = usuario_id );

create policy "Users can update own sessions"
  on public.sesiones_trabajo for update
  using ( auth.uid() = usuario_id );

-- History: Users can read history of their own sessions
-- Note: usage of join or exists is needed to check ownership via session
create policy "Users can view own history"
  on public.historial_acciones for select
  using (
    exists (
      select 1 from public.sesiones_trabajo s
      where s.id = historial_acciones.sesion_id
      and s.usuario_id = auth.uid()
    )
  );

-- Trigger to automatically create profile on signup
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.perfiles (id, nombre_completo, rol)
  values (new.id, new.raw_user_meta_data ->> 'full_name', 'empleado');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
