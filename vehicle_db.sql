create table users(
    userid integer generated by default as identity(start with 100 increment by 1),
    name varchar2(100) not null,
    email varchar2(100) not null unique,
    password varchar2(100) not null,
    country varchar2(100),
    city varchar2(100),
    area varchar2(100),
    longitude number(12, 8),
    latitude number(12, 8) not null,
    constraint pk_users primary key (userid)
);

create table garage(
    garageid integer generated always as identity(start with 1 increment by 1),
    ownerid integer not null,
    country varchar2(30) not null,
    city varchar2(30) not null,
    area varchar2(30) not null,
    name varchar2(100) not null,
    longitude number(12, 8) not null,
    latitude number(12, 8) not null,
    status integer not null,
    constraint pk_garage primary key (garageid),
    constraint fk_owner foreign key (ownerid) references users(userid),
    constraint unq_garage_info unique (country, city, area, name)
);

create table rent_info(
    garageid integer not null,
    vehicletype varchar2(100) not null,
    costlong number(12, 4) default 0,
    costshort number(12, 4) default 0,
    leftlong integer default 0,
    leftshort integer default 0,
    constraint fk_garageid foreign key (garageid) references garage(garageid),
    constraint un_rent_info unique(garageid, vehicletype)
);

create table vehicle_info(
    vehicleno varchar2(100) not null,
    vehicle_owner integer not null,
    vehicletype varchar2(100) not null,
    vehicle_model varchar2(100) not null,
    vehicle_company varchar2(100) not null,
    vehicle_color varchar2(100) not null,
    constraint pk_vehicleno primary key (vehicleno),
    constraint fk_vehicle_owner foreign key (vehicle_owner) references users(userid)
);

create table has_payment(
    vehicleno varchar2(100) not null,
    garageid integer not null,
    st_date date not null,
    payment_amount number(12, 4) default 0,
    servicetype varchar2(100) default 'SHORT',
    constraint fk_vehicleno_has_payment foreign key (vehicleno) references vehicle_info(vehicleno),
    constraint fk_garageid_has_payment foreign key (garageid) references garage(garageid),
    constraint unq_has_payment unique(vehicleno)
);

create table takes_service(
    serviceid integer generated always as identity (start with 1 increment by 1),
    garageid integer,
    vehicleno varchar2(100),
    servicetype varchar2(100) not null,
    start_time date not null,
    end_time date not null,
    total_amount number(12, 4) not null,
    paid number(12, 4) not null,
    constraint pk_serviceid primary key (serviceid),
    constraint fk_garageid_takes_service foreign key (garageid) references garage(garageid),
    constraint fk_vehicleno_takes_service foreign key (vehicleno) references vehicle_info(vehicleno)
);

--  Functions & Procedures

create or replace procedure insert_rent_data(gid in garage.garageid%type)
as
begin
    insert into rent_info(garageid, vehicletype)
    values (gid, 'CAR');
    insert into rent_info(garageid, vehicletype)
    values (gid, 'JEEP');
    insert into rent_info(garageid, vehicletype)
    values (gid, 'BIKE');
    insert into rent_info(garageid, vehicletype)
    values (gid, 'MICRO');
end;

create or replace type park_vehicle_price as object(
    garageid integer,
    ownerid integer,
    country varchar2(30),
    city varchar2(30),
    area varchar2(30),
    name varchar2(100),
    longitude number(12, 8),
    latitude number(12, 8),
    status integer,
    vehicletype varchar2(20),
    costshort number(12, 4),
    costlong number(12, 4),
    leftshort integer,
    leftlong integer
);

create or replace type park_vehicle_price_table as table of park_vehicle_price;

create or replace function show_parks(vtype in rent_info.vehicletype%type, plon in garage.longitude%type, plat in garage.latitude%type)
return park_vehicle_price_table
as
    parks_array park_vehicle_price_table;
    cursor all_parks 
    is 
        select g.*, r.vehicletype, r.costshort, r.costlong, r.leftshort, r.leftlong
        from garage g join rent_info r on g.garageid = r.garageid
        where r.vehicletype=vtype 
        order by abs(g.longitude - plon) + abs(g.latitude - plat) fetch first 20 rows only;
begin
    parks_array := park_vehicle_price_table();
    for park_row in all_parks
    loop
        parks_array.extend;
        parks_array(parks_array.count) := park_vehicle_price(
            park_row.garageid,
            park_row.ownerid,
            park_row.country,
            park_row.city,
            park_row.area,
            park_row.name,
            park_row.longitude,
            park_row.latitude,
            park_row.status,
            park_row.vehicletype,
            park_row.costshort,
            park_row.costlong,
            park_row.leftshort,
            park_row.leftlong);            
    end loop;
    return parks_array;
end;

create or replace procedure entryvehicle(
    vno in vehicle_info.vehicleno%type, 
    gid in garage.garageid%type, 
    pamnt in has_payment.payment_amount%type, 
    stype in has_payment.servicetype%type
)
as
begin
    insert into has_payment values(vno, gid, CURRENT_TIMESTAMP, pamnt, stype);
    update rent_info
    set leftlong = leftlong - (
        case 
            when stype='LONG' then 1
            else 0
        end
    ), leftshort = leftshort - (
        case
            when stype='SHORT' then 1
            else 0
        end
    )
    where garageid=gid and vehicletype = (select vehicletype from vehicle_info where vehicleno = vno);
end;

create or replace procedure exitvehicle(
    vno in vehicle_info.vehicleno%type, 
    gid in garage.garageid%type,  
    stype in has_payment.servicetype%type,
    tamnt in takes_service.total_amount%type,
    pd in takes_service.paid%type
)
as
    st_time date;
begin
    update rent_info
    set leftlong = leftlong + (
        case 
            when stype='LONG' then 1
            else 0
        end
    ), leftshort = leftshort + (
        case
            when stype='SHORT' then 1
            else 0
        end
    )
    where garageid=gid and vehicletype = (select vehicletype from vehicle_info where vehicleno = vno);
    
    select st_date into st_time from has_payment
    where vehicleno=vno and garageid=gid;
    
    insert into takes_service(garageid, vehicleno, servicetype, start_time, end_time, total_amount, paid)
    values (gid, vno, stype, st_time, CURRENT_TIMESTAMP, tamnt, pd);
    
    delete from has_payment
    where vehicleno=vno and garageid=gid;
end;