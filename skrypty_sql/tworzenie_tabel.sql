go
create table Turniej
(
id int identity constraint pk_turniej primary key,
nazwa nvarchar(40) unique,
pierwsze_miejsce float,
drugie_miejsce float,
trzecie_miejsce float,
data_rozpoczecia date,
data_konca date
)
create table Miasto
(
id int identity constraint pk_miasto primary key,
nazwa nvarchar(40)
)
create table Sedzia
(
pesel char(11) constraint pk_sedzia primary key,
id_miasto int constraint sedzia_miasto_fk foreign key references
Miasto(id),
imie nvarchar(40),
nazwisko nvarchar(40),
rozpoczecie_zawodu date,
klasa int,
)
create table Boisko
(
id int identity constraint boisko_sedzia primary key,
id_miasto int constraint boisko_miasto_fk foreign key references
Miasto(id),
nazwa nvarchar(40) constraint boisko_unique unique
)
create table Druzyna
(
id int identity constraint pk_druzyna primary key,
id_miasto int constraint druzyna_miasto_fk foreign key references
Miasto(id),
nazwa nvarchar(40)
)
create table Zawodnik
(
pesel char(11) constraint pk_zawodnik primary key,
id_druzyna int constraint zawodnik_druzyna_fk foreign key references
Druzyna(id),
imie nvarchar(40),
nazwisko nvarchar(40)
)
create table Mecz
(
id int identity constraint pk_mecz primary key,
id_turniej int constraint fk_mecz_turniej foreign key references
Turniej(id) not null,
druzyna_1 int constraint fk_mecz_druzyna_1 foreign key references
Druzyna(id),
druzyna_2 int constraint fk_mecz_druzyna_2 foreign key references
Druzyna(id),
id_sedzia char(11) constraint fk_mecz_sedzia foreign key references
Sedzia(pesel),
id_boisko int constraint fk_mecz_boisko foreign key references Boisko(id),
sety_druzyna_1 int,
sety_druzyna_2 int,
data date
)
go