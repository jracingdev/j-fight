-- ============================================================
-- CT SM BJJ — Correção de roles no cadastro (execute no Supabase)
-- ============================================================

create or replace function public.handle_new_user()
returns trigger as $$
declare
  v_email text := lower(trim(coalesce(new.email, '')));
  v_role text := 'aluno';
begin
  if v_email = 'admin@smbj.com' then
    v_role := 'admin';
  end if;

  insert into public.usuarios (id, nome, email, role, foto_url)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data->>'full_name',
      new.raw_user_meta_data->>'name',
      split_part(v_email, '@', 1)
    ),
    coalesce(new.email, v_email),
    v_role,
    new.raw_user_meta_data->>'avatar_url'
  )
  on conflict (id) do update set
    email = excluded.email,
    nome = coalesce(public.usuarios.nome, excluded.nome),
    foto_url = coalesce(public.usuarios.foto_url, excluded.foto_url);

  return new;
end;
$$ language plpgsql security definer set search_path = public;

-- Corrige contas que ficaram admin por engano (mantém só admin@smbj.com)
update public.usuarios
set role = 'aluno'
where role = 'admin'
  and lower(trim(email)) <> 'admin@smbj.com';

select 'Auth fix aplicado' as status;
