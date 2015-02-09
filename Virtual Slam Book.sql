CREATE FUNCTION insert_friend_media() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
t friend_media.type%type;
begin
	if new.type='Photo' then
	     insert into friend_media(media_id,type,destination,photo) values(new.media_id,new.type,new.destination,lo_import(new.destination));
	else if new.type='video' then
	insert into friend_media(media_id,type,destination,video) values(new.media_id,new.type,new.destination,lo_import(new.destination));
	else
	raise exception 'Invalid Type';
	end if;
	end if;
	return new;
end
$$;

CREATE FUNCTION moments_friends_name(character varying) RETURNS SETOF character varying
    LANGUAGE plpgsql
    AS $_$
declare 
f friend_details.friend_name%type;
c cursor for select * from friend_moments natural join moments natural join  friend_details 
where friend_moments.moment_id=moments.moment_id and moments.friend_id=friend_details.friend_id and friend_moments.moments_name=$1;
begin
	open c;
	loop
	fetch c into f;
	if not exists(select * from friend_moments natural join moments natural join  friend_details 
		where friend_moments.moment_id=moments.moment_id and moments.friend_id=friend_details.friend_id and friend_moments.moments_name=$1)
		then
		raise exception 'Sorry no such moment exits';
	end if;	
		
	return next f;
	exit when not found;
	end loop;
end
$_$;

CREATE FUNCTION open_media(character varying, character varying, character varying) RETURNS void
    LANGUAGE plpgsql
    AS $_$
declare
r friend_media.photo%type;
v friend_media.video%type;
n friend_media.destination%type;
c cursor for select photo,video,destination from friend_media;
begin
	open c;
	loop
	fetch c into r,v,n;
	if n=$2 then
		if $1='photo' then
		perform lo_export(r,$3) from friend_media;
		else if $1='video' then
		perform lo_export(v,$3) from friend_media;	
		else
		raise exception 'Invalid Type';
		end if;
		end if;
	end if;	
	exit when not found;
	end loop;
end
$_$;

CREATE FUNCTION test(character varying, character varying) RETURNS SETOF character varying
    LANGUAGE plpgsql
    AS $_$
declare
n friend_details.friend_name%type;
r cursor for (select friend_name from category natural join belongs_to natural join  friend_details 
	where category.category_id=belongs_to.category_id and belongs_to.friend_id=friend_details.friend_id and category.category_name=$1)
	intersect
	(select friend_name from category natural join belongs_to natural join  friend_details 
	where category.category_id=belongs_to.category_id and belongs_to.friend_id=friend_details.friend_id and category.category_name=$2);
begin
	open r;
	loop
	fetch r into n;
	return next n;
	exit when not found;
	end loop;
end
$_$;

CREATE TABLE belongs_to (
    category_id character varying(20),
    friend_id character varying(20)
);

CREATE TABLE category (
    category_id character varying(20) NOT NULL,
    category_name character varying(50) NOT NULL,
    category_period character varying(20)
);

CREATE TABLE friend_details (
    friend_id character varying(20) NOT NULL,
    friend_name character varying(50) NOT NULL,
    friend_nick_name character varying(50),
    date_of_birth date,
    address character varying(100),
    mobile_no_1 character varying(15),
    mobile_no_2 character varying(15),
    email_1 character varying(50),
    email_2 character varying(50),
    description character varying(50),
    media_id character varying(5)
);

CREATE TABLE friend_media (
    media_id character varying(5) NOT NULL,
    type character varying(10),
    photo oid,
    video oid,
    destination character varying(100)
);

CREATE TABLE friend_moments (
    moment_id character varying(20) NOT NULL,
    moment_time timestamp without time zone,
    moment_description character varying(1000),
    moments_name character varying(50)
);

CREATE VIEW insert_media_view AS
 SELECT friend_media.media_id,
    friend_media.type,
    friend_media.destination
   FROM friend_media;


CREATE TABLE media (
    media_id character varying(5),
    moment_id character varying(5)
);

CREATE TABLE moments (
    friend_id character varying(20),
    moment_id character varying(20)
);

CREATE TABLE test (
    sl_no integer NOT NULL,
    name character varying(20)
);

CREATE TABLE vi (
    vid integer NOT NULL,
    video oid
);

