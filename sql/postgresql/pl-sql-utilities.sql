--
-- pl-sql.sql 
-- 
-- created by philg on 11/18/98
--
-- useful pl/sql utility procedures 
--

-- useful for ecommerce and other situations where you want to
-- know whether something happened within last N days (assumes query_date
-- is in the past)

create function one_if_within_n_days (timestamp, integer)
returns integer as '
declare
  query_date		alias for $1;
  n_days		alias for $2;
begin
  if current_timestamp - query_date <= timespan_days(n_days) then 
    return 1;
  else
    return 0;
  end if;
end;' language 'plpgsql';

create function pseudo_contains (varchar, varchar)
returns integer as '
declare
  indexed_stuff  		alias for $1;
  space_sep_list_untrimmed alias for $2;
  space_sep_list        	text;
  upper_indexed_stuff   	text;
  -- if you call this var start you get hosed royally
  first_space           	integer;
  score                 	integer;
begin 
  space_sep_list := upper(ltrim(rtrim(space_sep_list_untrimmed)));
  upper_indexed_stuff := upper(indexed_stuff);
  score := 0;
  if space_sep_list is null or indexed_stuff is null then
    return score;  
  end if;
  loop
   first_space := position('' '' in space_sep_list);
   if first_space = 0 then
     -- one token or maybe end of list
     if position(space_sep_list in upper_indexed_stuff) <> 0 then
        return score+10;
     end if;
     return score;
   else
     -- first_space <> 0
     if position(substring(space_sep_list from 1 for first_space-1) in upper_indexed_stuff) <> 0 then
        score := score + 10;
     end if;
   end if;
    space_sep_list := substring(space_sep_list from first_space+1);
  end loop;  
end;' language 'plpgsql';
