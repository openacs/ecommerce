--
-- pl-sql.sql 
-- 
-- created by philg on 11/18/98
--
-- useful pl/sql utility procedures 
--

-- gilbertw - logical_negation is defined in utilities-create.sql in acs-kernel
-- create function logical_negation (boolean)
-- returns boolean as '
-- DECLARE
--   true_or_false		alias for $1;
-- BEGIN
--   IF true_or_false is null THEN
-- 	return null;
--   ELSE
-- 	IF true_or_false = ''f'' THEN
--     	    return ''t'';   
--   	ELSE 
-- 	    return ''f'';   
-- 	END IF;
--   END IF;
-- END;' language 'plpgsql';

-- useful for ecommerce and other situations where you want to
-- know whether something happened within last N days (assumes query_date
-- is in the past)

create function one_if_within_n_days (timestamp, integer)
returns integer as '
declare
  query_date		alias for $1;
  n_days		alias for $2;
begin
  IF current_timestamp - query_date <= timespan_days(n_days) THEN 
    return 1;
  ELSE
    return 0;
  END IF;
end;' language 'plpgsql';

create function pseudo_contains (varchar, varchar)
returns integer as '
DECLARE
  indexed_stuff			alias for $1;
  space_sep_list_untrimmed	alias for $2;
  space_sep_list        	text;
  upper_indexed_stuff   	text;
  -- if you call this var START you get hosed royally
  first_space           	integer;
  score                 	integer;
BEGIN 
  space_sep_list := upper(ltrim(rtrim(space_sep_list_untrimmed)));
  upper_indexed_stuff := upper(indexed_stuff);
  score := 0;
  IF space_sep_list is null or indexed_stuff is null THEN
    RETURN score;  
  END IF;
  LOOP
   first_space := position('' '' in space_sep_list);
   IF first_space = 0 THEN
     -- one token or maybe end of list
     IF position(space_sep_list in upper_indexed_stuff) <> 0 THEN
        RETURN score+10;
     END IF;
     RETURN score;
   ELSE
   -- first_space <> 0
     IF position(substring(space_sep_list from 1 to first_space-1) in upper_indexed_stuff) <> 0 THEN
        score := score + 10;
     END IF;
   END IF;
    space_sep_list := substring(space_sep_list from first_space+1);
  END LOOP;  
END;' language 'plpgsql';

