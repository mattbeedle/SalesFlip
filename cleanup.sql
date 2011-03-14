UPDATE leads SET last_name = substring(last_name, '[[:space:]]*(.+?)[[:space:]]*') WHERE last_name ~ E'(^[[:space:]])|([[:space:]]$)';
UPDATE leads SET first_name = substring(first_name, '[[:space:]]*(.+?)[[:space:]]*') WHERE first_name ~ E'(^[[:space:]])|([[:space:]]$)';
UPDATE leads SET company = substring(company, '[[:space:]]*(.+?)[[:space:]]*') WHERE company ~ E'(^[[:space:]])|([[:space:]]$)';
UPDATE leads SET phone = substring(phone, '[[:space:]]*(.+?)[[:space:]]*') WHERE phone ~ E'(^[[:space:]])|([[:space:]]$)';
UPDATE leads SET email = substring(email, '[[:space:]]*(.+?)[[:space:]]*') WHERE email ~ E'(^[[:space:]])|([[:space:]]$)';
UPDATE leads SET website = substring(website, '[[:space:]]*(.+?)[[:space:]]*') WHERE website ~ E'(^[[:space:]])|([[:space:]]$)';

UPDATE contacts SET last_name = substring(last_name, '[[:space:]]*(.+?)[[:space:]]*') WHERE last_name ~ E'(^[[:space:]])|([[:space:]]$)';
UPDATE contacts SET first_name = substring(first_name, '[[:space:]]*(.+?)[[:space:]]*') WHERE first_name ~ E'(^[[:space:]])|([[:space:]]$)';

UPDATE accounts SET name = substring(name, '[[:space:]]*(.+?)[[:space:]]*') WHERE name ~ E'(^[[:space:]])|([[:space:]]$)';

select count(
  distinct
    regexp_replace(
      lower(company),
      E'(.*) (ag|systems|holding|gmbh|gmbh & co. kg|mbh|e\.\\s?v\.)$',
      E'\\1',
      'g'
    )
) from leads ;

select company from leads where company ~ 'EV';
select company from leads where company ~* 'kgaa';

select count(
  distinct
  regexp_replace(
    regexp_replace(
      regexp_replace(
        regexp_replace(
          lower(company),
          E'(.*) (ag|systems|holding|gmbh|gmbh & co. kg|mbh|e\.\\s?v\.)$',
          E'\\1',
          'g'
        ),
        'ü', 'ue'
      ),
      'ö', 'oe'
    ),
    'ä', 'ae'
  )
) from leads ;

        ü: "ue"
        ö: "oe"
        ä: "ae"

-- substring search: 4voice AG vs. 4voice AG, Sprachtechnologien aus einer Hand
--  GmbH & Co. KG
--  Holding
--  mbH
--  e.v. e. V.
