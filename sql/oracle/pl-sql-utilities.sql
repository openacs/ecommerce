--
-- pl-sql.sql 
-- 
-- created by philg on 11/18/98
--
-- useful pl/sql utility procedures 
--

create or replace function logical_negation(true_or_false IN varchar)
return varchar
is
BEGIN
  IF true_or_false is null THEN
    return null;
  ELSIF true_or_false = 'f' THEN
    return 't';   
  ELSE 
    return 'f';   
  END IF;
END logical_negation;
/
show errors

-- useful for ecommerce and other situations where you want to
-- know whether something happened within last N days (assumes query_date
-- is in the past)

create or replace function one_if_within_n_days (query_date IN date, n_days IN integer)
return integer
is
begin
  IF (sysdate - query_date) <= n_days THEN 
    return 1;
  ELSE
    return 0;
  END IF;
end one_if_within_n_days;
/
show errors

create or replace function pseudo_contains (indexed_stuff IN varchar, space_sep_list_untrimmed IN varchar)
return integer
IS
  space_sep_list        varchar(32000);
  upper_indexed_stuff   varchar(32000);
  -- if you call this var START you get hosed royally
  first_space           integer;
  score                 integer;
BEGIN 
  space_sep_list := upper(ltrim(rtrim(space_sep_list_untrimmed)));
  upper_indexed_stuff := upper(indexed_stuff);
  score := 0;
  IF space_sep_list is null or indexed_stuff is null THEN
    RETURN score;  
  END IF;
  LOOP
   first_space := instr(space_sep_list,' ');
   IF first_space = 0 THEN
     -- one token or maybe end of list
     IF instr(upper_indexed_stuff,space_sep_list) <> 0 THEN
        RETURN score+10;
     END IF;
     RETURN score;
   ELSE
   -- first_space <> 0
     IF instr(upper_indexed_stuff,substr(space_sep_list,1,first_space-1)) <> 0 THEN
        score := score + 10;
     END IF;
   END IF;
    space_sep_list := substr(space_sep_list,first_space+1);
  END LOOP;  
END pseudo_contains;
/
show errors

