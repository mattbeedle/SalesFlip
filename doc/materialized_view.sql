
    drop table if exists "lead_permissions";

    create or replace view lead_permissions_unmaterialized as
    select "leads"."id" as "lead_id",
           "users"."id" as "user_id"
      from "leads",
           "users"
     where "leads"."user_id" = "users"."id"
        or "leads"."assignee_id" = "users"."id"
        or "permission" = 1
        or "leads"."id" in ( select "leads"."id"
                               from "leads"
                         inner join "lead_permitted_users" on "leads"."id" = "lead_permitted_users"."lead_id"
                              where "leads"."permission" = 2 and "lead_permitted_users"."permitted_user_id" = "users"."id" );

    create table "lead_permissions" as
    select *
      from lead_permissions_unmaterialized;

    create index index_lead_permissions_lead_id on lead_permissions (lead_id);
    create index index_lead_permissions_user_id on lead_permissions (user_id);

    create or replace function refresh_lead_permissions(
      id integer
    ) returns void
    security definer
    language 'plpgsql' as $$
    begin
      delete from lead_permissions lp where lp.lead_id = id;
      insert into lead_permissions
      select *
        from lead_permissions_unmaterialized lpm
       where lpm.lead_id = id;
    end
    $$;

    -- insert
    create or replace function refresh_lead_permissions_on_leads_insert() returns trigger
    security definer
    language 'plpgsql' as $$
    begin
      perform refresh_lead_permissions(new.id);
      return null;
    end
    $$;

    drop trigger if exists refresh_lead_permissions_on_leads_insert on leads;
    create trigger refresh_lead_permissions_on_leads_insert after insert on leads
      for each row execute procedure refresh_lead_permissions_on_leads_insert();

    -- delete
    create or replace function refresh_lead_permissions_on_leads_delete() returns trigger
    security definer
    language 'plpgsql' as $$
    begin
      perform refresh_lead_permissions(old.id);
      return null;
    end
    $$;

    drop trigger if exists refresh_lead_permissions_on_leads_delete on leads;
    create trigger refresh_lead_permissions_on_leads_delete after delete on leads
      for each row execute procedure refresh_lead_permissions_on_leads_delete();

    -- update
    create or replace function refresh_lead_permissions_on_leads_update() returns trigger
    security definer
    language 'plpgsql' as $$
    begin
      perform refresh_lead_permissions(new.id);
      return null;
    end
    $$;

    drop trigger if exists refresh_lead_permissions_on_leads_update on leads;
    create trigger refresh_lead_permissions_on_leads_update after update on leads
      for each row execute procedure refresh_lead_permissions_on_leads_update();
