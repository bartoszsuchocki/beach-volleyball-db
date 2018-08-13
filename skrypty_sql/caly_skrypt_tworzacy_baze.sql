/*Ewentualne usuwanie tabel, procedur, trigerów
drop trigger dodawanie_mecz_dwie_rozne_druzyny_sprawdzenie
drop trigger edycja_nagrody_sprawdzenie
drop trigger usuwanie_zawodnik_sprawdzenie
drop trigger usuwanie_turniej_sprawdzenie
drop trigger edycja_skladu_druzyny_sprawdzenie
drop trigger zawodnik_do_druzyny_sprawdzenie
drop trigger mecz_sprawdzenie_daty
drop table Mecz
drop table Zawodnik
drop table Druzyna
drop table Boisko
drop table Sedzia
drop table Miasto
drop table Turniej
drop procedure dodaj_turniej
drop procedure dodaj_miasto
drop procedure dodaj_sedzia
drop procedure dodaj_boisko
drop procedure dodaj_druzyna
drop procedure dodaj_zawodnik
drop procedure dodaj_mecz
drop procedure edytuj_turniej
drop procedure edytuj_miasto
drop procedure edytuj_sedzia
drop procedure edytuj_zawodnik
drop procedure edytuj_mecz
drop procedure edytuj_druzyna
drop procedure edytuj_boisko
drop procedure dodaj_mecz_sedzia
drop procedure dodaj_druzyna_zawodnicy
*/
						/*Stworzenie bazy danych o nazwie 'siatkarska_baza'*/
if not exists(select 1 from master.dbo.sysdatabases sdb where sdb.name='siatkarska_baza')
begin
print 'Tworzê now¹ bazê.'
create database siatkarska_baza
end
go
use siatkarska_baza


									/*Tworzenie tabel*/
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
						
								/*Tworzenie procedur*/
/*Wstawia nowy rekord do tabeli Turniej.*/
create procedure dodaj_turniej
(
@nazwa nvarchar(40),
@nagroda_1 float,
@nagroda_2 float,
@nagroda_3 float,
@data_rozpoczecia date,
@data_konca date
)
as
insert into Turniej
values(@nazwa,@nagroda_1,@nagroda_2,@nagroda_3,@data_rozpoczecia,@data_konca)
go

/*Modyfikuje wybrany rekord w tabeli Turniej.*/
create procedure edytuj_turniej
(
@nazwa nvarchar(40),
@poprzednia_data_rozpoczecia date,
@nagroda_1 float=null,
@nagroda_2 float=null,
@nagroda_3 float=null,
@data_rozpoczecia date=null,
@data_konca date=null
)
as
update Turniej
set
pierwsze_miejsce = ISNULL(@nagroda_1,pierwsze_miejsce),
drugie_miejsce = ISNULL(@nagroda_2,drugie_miejsce),
trzecie_miejsce = ISNULL(@nagroda_3,trzecie_miejsce)
where nazwa=@nazwa and data_rozpoczecia=@poprzednia_data_rozpoczecia
go

/*Dodaje nowy rekord do tabeli Miasto.*/
create procedure dodaj_miasto
(
@nazwa nvarchar(40)
)
as
insert into Miasto values(@nazwa)
go

/*Edytuje wybrany rekord w tabeli Miasto.*/
create procedure edytuj_miasto
(
@id_miasta int,
@nazwa nvarchar(40)
)
as
update Miasto
set nazwa = @nazwa
where id=@id_miasta
go
/*Dodaje nowy rekord do tabeli Sedzia.*/
create procedure dodaj_sedzia
(
@pesel char(11),
@nazwa_miasta nvarchar(40),
@imie nvarchar(40),
@nazwisko nvarchar(40),
@rozpoczecie_zawodu date,
@klasa int
)
as
insert into Sedzia values(@pesel,(select top 1 m.id from Miasto m where
nazwa=@nazwa_miasta),@imie,@nazwisko,@rozpoczecie_zawodu,@klasa)
go

/*Edytuje wybrany wiersz w tabeli Sedzia.*/
create procedure edytuj_sedzia
(
@pesel char(11),
@nazwa_miasta nvarchar(40)=null,
@imie nvarchar(40)=null,
@nazwisko nvarchar(40)=null,
@rozpoczecie_zawodu date=null,
@klasa int=null
)
as
update Sedzia
set
id_miasto = ISNULL((select top 1 m.id from Miasto m where
nazwa=@nazwa_miasta),id_miasto),
imie = ISNULL(@imie,imie),
nazwisko = ISNULL(@nazwisko,nazwisko),
rozpoczecie_zawodu = ISNULL(@rozpoczecie_zawodu,rozpoczecie_zawodu),
klasa = ISNULL(@klasa,klasa)
where pesel = @pesel
go

/*Dodaje nowy rekord do tabeli Boisko*/
create procedure dodaj_boisko
(
@nazwa_miasta nvarchar(40),
@nazwa nvarchar(40)
)
as
insert into Boisko values((select top 1 m.id from Miasto m where
nazwa=@nazwa_miasta),@nazwa)
go

/*Edytuje wybrany rekord w tabeli Boisko*/
create procedure edytuj_boisko
(
@nazwa_boiska nvarchar(40),
@nazwa_miasta nvarchar(40)
)
as
update Boisko
set
id_miasto = ISNULL((select top 1 m.id from Miasto m where
nazwa=@nazwa_miasta),id_miasto)
where nazwa = @nazwa_boiska
go

/*Dodaje nowy rekord do tabeli Druzyna.*/
create procedure dodaj_druzyna
(
@nazwa_miasta nvarchar(40),
@nazwa nvarchar(40)
)
as
insert into Druzyna values((select top 1 m.id from Miasto m where
nazwa=@nazwa_miasta),@nazwa)
go

/*Edytuje wybrany rekord w tabeli Druzyna.*/
create procedure edytuj_druzyna
(
@nazwa_druzyny nvarchar(40),
@nazwa_miasta nvarchar(40)=null
)
as
update Druzyna
set
id_miasto = ISNULL((select top 1 m.id from Miasto m where
nazwa=@nazwa_miasta),id_miasto)
where nazwa=@nazwa_druzyny
go

/*Dodaje nowy rekord do tabeli Zawodnik.*/
create procedure dodaj_zawodnik
(
@pesel char(11),
@nazwa_druzyny nvarchar(40),
@imie nvarchar(40),
@nazwisko nvarchar(40)
)
as
insert into Zawodnik values(@pesel,(select top 1 d.id from Druzyna d where
nazwa=@nazwa_druzyny),@imie,@nazwisko)
go

/*Edytuje wybrany rekord w tabeli Zawodnik.*/
create procedure edytuj_zawodnik
(
@pesel char(11)=null,
@nazwa_druzyny nvarchar(40)=null,
@imie nvarchar(40)=null,
@nazwisko nvarchar(40)=null
)
as
update Zawodnik
set
id_druzyna = ISNULL((select top 1 d.id from Druzyna d where
nazwa=@nazwa_druzyny),id_druzyna),
imie = ISNULL(@imie,imie),
nazwisko = ISNULL(@nazwisko,nazwisko)
where pesel = @pesel
go

/*Dodaje nowy rekord do tabeli Mecz.*/
create procedure dodaj_mecz
(
@nazwa_turnieju nvarchar(30),
@data_rozpoczecia_turnieju date,
@druzyna_1_nazwa nvarchar(40),
@druzyna_2_nazwa nvarchar(40),
@sedzia_pesel char(11),
@nazwa_boisko nvarchar(40),
@sety_druzyna_1 int,
@sety_druzyna_2 int,
@data date
)
as
insert into Mecz values((select t.id from Turniej t where
nazwa=@nazwa_turnieju and data_rozpoczecia=@data_rozpoczecia_turnieju)
,(select d.id from Druzyna d where nazwa=@druzyna_1_nazwa) ,(select d.id
from Druzyna d where nazwa=@druzyna_2_nazwa),
@sedzia_pesel,(select b.id from Boisko b where
nazwa=@nazwa_boisko),@sety_druzyna_1,@sety_druzyna_2, @data)
go
/*Edytuje wybrany rekord w tabeli Mecz.*/
create procedure edytuj_mecz
(
@id_meczu int,
@nazwa_turnieju nvarchar(40)=null,
@data_rozpoczecia_turnieju date=null,
@druzyna_1_nazwa nvarchar(40)=null,
@druzyna_2_nazwa nvarchar(40)=null,
@sedzia_pesel char(11)=null,
@nazwa_boisko nvarchar(40)=null,
@sety_druzyna_1 int=null,
@sety_druzyna_2 int=null,
@data date=null
)
as
update Mecz
set
id_turniej = ISNULL((select t.id from Turniej t where
nazwa=@nazwa_turnieju and
data_rozpoczecia=@data_rozpoczecia_turnieju),id_turniej),
druzyna_1 = ISNULL((select d.id from Druzyna d where
nazwa=@druzyna_1_nazwa),druzyna_1),
druzyna_2 = ISNULL((select d.id from Druzyna d where
nazwa=@druzyna_2_nazwa),druzyna_2),
id_sedzia = ISNULL(@sedzia_pesel,id_sedzia),
id_boisko = ISNULL((select b.id from Boisko b where
nazwa=@nazwa_boisko),id_boisko),
sety_druzyna_1 = ISNULL(@sety_druzyna_1,sety_druzyna_1),
sety_druzyna_2 = ISNULL(@sety_druzyna_2,sety_druzyna_2),
data = ISNULL(@data,data)
where id=@id_meczu
go

/*Dodaje jednoczeœnie nowy rekord do tabeli Mecz 
oraz nowy rekord (sêdzia sêdziuj¹cy w tym meczu) do tabeli Sedzia.*/
create procedure dodaj_mecz_sedzia
(
	@turniej_nazwa nvarchar(30),
	@turniej_data_rozpoczecia date,
	@mecz_druzyna_1_nazwa nvarchar(40),
	@mecz_druzyna_2_nazwa nvarchar(40),
	@sedzia_pesel char(11),
	@sedzia_miasto nvarchar(40),
	@sedzia_imie nvarchar(40),
	@sedzia_nazwisko nvarchar(40),
	@sedzia_rozpoczecie_zawodu date,
	@sedzia_klasa int,
	@boisko_nazwa nvarchar(40),
	@sety_druzyna_1 int,
	@sety_druzyna_2 int,
	@mecz_data date
)
as
declare @trCnt int
set @trCnt = @@TRANCOUNT
declare @err int
set @err=0

if @trCnt=0
begin
	begin tran transakcja
end
else
begin
	save tran transakcja
end 
exec dodaj_sedzia @sedzia_pesel,sedzia_miasto,@sedzia_imie,@sedzia_nazwisko,@sedzia_rozpoczecie_zawodu,
	@sedzia_klasa
set @err=@@ERROR
if @err=0
begin
	exec dodaj_mecz @turniej_nazwa,@turniej_data_rozpoczecia,@mecz_druzyna_1_nazwa,@mecz_druzyna_2_nazwa,
		@sedzia_pesel,@boisko_nazwa,@sety_druzyna_1,@sety_druzyna_2,@mecz_data
	set @err=@@ERROR
end
if @err=0
	commit tran transakcja
else
begin
	print 'Nie udalo sie dodac meczu i sedziego!'
	rollback tran transakcja
end
go

/*Dodaje nowy rekord do tabeli Druzyna oraz dwa nowe (zawodnicy nale¿¹cy do tej dru¿yny)
 do tabeli Zawodnik.*/
create procedure dodaj_druzyna_zawodnicy
(
	@druzyna_nazwa nvarchar(40),
	@druzyna_miasto nvarchar(40),
	@pesel_1 char(11),
	@imie_1 nvarchar(40),
	@nazwisko_1 nvarchar(40),
	@pesel_2 char(11),
	@imie_2 nvarchar(40),
	@nazwisko_2 nvarchar(40)
)
as
declare @trCnt int
set @trCnt = @@TRANCOUNT
declare @err int
set @err=0

if @trCnt=0
begin
	begin tran transakcja
end
else
begin
	save tran transakcja
end
exec dodaj_druzyna @druzyna_miasto,@druzyna_nazwa 
set @err=@@ERROR
if @err=0
begin
	exec dodaj_zawodnik @pesel_1,@druzyna_nazwa,@imie_1,@nazwisko_1 
	set @err=@@ERROR
end
if @err=0
begin
	exec dodaj_zawodnik @pesel_2,@druzyna_nazwa,@imie_2,@nazwisko_2 
	set @err=@@ERROR
end
if @err=0
	commit tran transakcja
else
begin
	print 'Nie udalo sie dodac nowej druzyny i zawodnikow!'
	rollback tran transakcja
end
go
									/*Zasilanie tabel*/
exec dodaj_miasto 'Warszawa'
exec dodaj_miasto 'Poznan'
exec dodaj_miasto 'Gdansk'
exec dodaj_miasto 'Sopot'
exec dodaj_miasto 'Lodz'
exec dodaj_miasto 'Katowice'
exec dodaj_miasto 'Radom'
exec dodaj_miasto 'Torun'
exec dodaj_miasto 'Bialystok'
exec dodaj_miasto 'Wroclaw'
exec dodaj_miasto 'Warka'
exec dodaj_miasto 'Zielona Gora'
exec dodaj_miasto 'Ustka'
exec dodaj_miasto 'Wieliczka'
exec dodaj_miasto 'Lublin'
exec dodaj_miasto 'Szczecin'
exec dodaj_miasto 'Bydgoszcz'
exec dodaj_miasto 'Swinoujscie'
exec dodaj_miasto 'Biskupiec'
exec dodaj_miasto 'Wadowice'

exec dodaj_sedzia '98033012789','Warszawa','Bartosz','Kowalski','2017-03-01',2
exec dodaj_sedzia '97033012789','Warszawa','Adam','Kowalski','2016-03-01',3
exec dodaj_sedzia '96033012789','Warszawa','Wiktor','Nowak','2015-05-02',3
exec dodaj_sedzia '95033012719','Warszawa','Kacper','Szalik','2018-05-03',1
exec dodaj_sedzia '94033012729','Warszawa','Arnold','Sloma','2018-03-01',3
exec dodaj_sedzia '92033012759','Wroclaw','Jakub','Kowal','2018-03-02',2
exec dodaj_sedzia '91033012789','Wroclaw','Weronika','Kowalska','2018-02-01',2
exec dodaj_sedzia '90033012759','Wroclaw','Adam','Plot','2009-11-09',2
exec dodaj_sedzia '89033012759','Bialystok','Sebastian','Kos','2011-03-12',1
exec dodaj_sedzia '88033012759','Bialystok','Waclaw','Kajak','2017-06-11',3
exec dodaj_sedzia '87033012759','Lublin','Szymon','Milerski','2017-04-08',1
exec dodaj_sedzia '86033012759','Lublin','Arkadiusz','Kowacic','2017-03-06',1
exec dodaj_sedzia '85033012759','Szczecin','Waclaw','Strzecha','2017-05-06',1
exec dodaj_sedzia '84033012759','Szczecin','Bartosz','Stypa','2017-05-01',3
exec dodaj_sedzia '83033012759','Warka','Jakub','Raban','2016-03-01',3
exec dodaj_sedzia '82033012759','Warka','Jakub','Astra','2016-05-11',3
exec dodaj_sedzia '81033012759','Ustka','Jakub','Syn','2015-03-11',2
exec dodaj_sedzia '80033012759','Ustka','Piotr','Hak','2015-11-08',1
exec dodaj_sedzia '79033012759','Lodz','Piotr','Wilk','2015-02-01',2
exec dodaj_sedzia '78033012759','Lodz','Adam','Mario','2014-02-07',1
exec dodaj_sedzia '76033012759','Katowice','Mateusz','Stonka','2013-02-01',3

exec dodaj_druzyna 'Warszawa','Mistrzowie'
exec dodaj_druzyna 'Warszawa','Gracze'
exec dodaj_druzyna 'Bialystok','Wilki'
exec dodaj_druzyna 'Bialystok','Tygrysy'
exec dodaj_druzyna 'Katowice','Ptaki'
exec dodaj_druzyna 'Sczecin','Zwierzeta'
exec dodaj_druzyna 'Ustka','Gile'
exec dodaj_druzyna 'Ustka','Sroki'
exec dodaj_druzyna 'Ustka','Gozdziki'
exec dodaj_druzyna 'Warszawa','Malutcy'
exec dodaj_druzyna 'Warszawa','Duzi'
exec dodaj_druzyna 'Wroclaw','Mali'
exec dodaj_druzyna 'Wroclaw','Sami'
exec dodaj_druzyna 'Wroclaw','Ogromni'
exec dodaj_druzyna 'Lublin','Wieloryby'
exec dodaj_druzyna 'Lublin','Ryby'
exec dodaj_druzyna 'Lodz','Kosy'
exec dodaj_druzyna 'Lodz','Kosiarki'
exec dodaj_druzyna 'Bialystok','Plazy'

exec dodaj_zawodnik '99102234567','Mistrzowie','Adam','Kowalik'
exec dodaj_zawodnik '98102234567','Mistrzowie','Sebastian','Stasiak'
exec dodaj_zawodnik '97102234567','Gracze','Adrian','Sowa'
exec dodaj_zawodnik '96102234567','Gracze','Kamil','Tarantula'
exec dodaj_zawodnik '95102234511','Duzi','Adam','Kowalik'
exec dodaj_zawodnik '95102234512','Duzi','Sebastian','Stasiak'
exec dodaj_zawodnik '95102234561','Mali','Adrian','Sowa'
exec dodaj_zawodnik '95102234513','Mali','Kamil','Tarantula'
exec dodaj_zawodnik '95102234514','Ryby','Adam','Kowalik'
exec dodaj_zawodnik '95102234515','Ryby','Sebastian','Stasiak'
exec dodaj_zawodnik '98102234516','Wieloryby','Adrian','Sowa'
exec dodaj_zawodnik '99102234517','Wieloryby','Kamil','Tarantula'
exec dodaj_zawodnik '98102234345','Sami','Adam','Kowalik'
exec dodaj_zawodnik '99102234417','Sami','Sebastian','Stasiak'
exec dodaj_zawodnik '97102234407','Plazy','Adrian','Sowa'
exec dodaj_zawodnik '96102233751','Plazy','Kamil','Tarantula'
exec dodaj_zawodnik '99102230927','Sroki','Adam','Kowalik'
exec dodaj_zawodnik '98102231184','Sroki','Sebastian','Stasiak'
exec dodaj_zawodnik '97102223419','Gile','Adrian','Sowa'
exec dodaj_zawodnik '96102235178','Gile','Kamil','Tarantula'

exec dodaj_boisko 'Warszawa','Plazowa mekka'
exec dodaj_boisko 'Wroclaw','Siatkarski olimp'
exec dodaj_boisko 'Warszawa','Siatka'
exec dodaj_boisko 'Warszawa','Plaza'
exec dodaj_boisko 'Wroclaw','Wartota'
exec dodaj_boisko 'Warszawa','Stonoga'
exec dodaj_boisko 'Bialystok','Senna stodola'
exec dodaj_boisko 'Bialystok','Sien'
exec dodaj_boisko 'Szczecin','Wiadro siatkowki'
exec dodaj_boisko 'Szczecin','Sypki piasek'
exec dodaj_boisko 'Ustka', 'Zielona siatka'
exec dodaj_boisko 'Ustka','Wir siatkowki'
exec dodaj_boisko 'Lublin','Plazowka biala'
exec dodaj_boisko 'Lublin','Ogromna siatka'
exec dodaj_boisko 'Lodz','Wielogrod siatkarski'
exec dodaj_boisko 'Lodz','Mekka plazowiczow'
exec dodaj_boisko 'Zielona gora','Boisko plazowe'
exec dodaj_boisko 'Warszawa','Malta'
exec dodaj_boisko 'Bialystok','Herakles'
exec dodaj_boisko 'Wroclaw','SiatFit'

exec dodaj_turniej 'Puchar miasta',2000,1000,500,'2018-02-01','2018-07-10'
exec dodaj_turniej 'Wielki turniej',2000,1000,500,'2018-05-01','2018-09-10'
exec dodaj_turniej 'Mini puchar',2000,1000,500,'2017-06-01','2017-06-10'
exec dodaj_turniej 'Puchar krola',1800,1000,500,'2017-02-01','2017-07-10'
exec dodaj_turniej 'Wielki piast',1800,1000,500,'2017-05-01','2017-09-10'
exec dodaj_turniej 'Mini puchar piasta',1800,1000,500,'2018-05-01','2018-06-10'
exec dodaj_turniej 'Puchar piasta',1800,1000,500,'2018-05-01','2018-07-11'
exec dodaj_turniej 'Wielki piasek',1200,1000,500,'2018-03-01','2018-09-11'
exec dodaj_turniej 'Mini ambroziak',1200,1000,500,'2018-11-01','2018-12-10'
exec dodaj_turniej 'Turniej walki',1200,1000,500,'2018-02-01','2018-09-10'
exec dodaj_turniej 'Wielki dzwon',2000,1000,500,'2018-05-01','2018-08-10'
exec dodaj_turniej 'Mini kalosz',2000,1000,500,'2018-02-01','2018-04-10'
exec dodaj_turniej 'Puchar starosty',2000,1000,500,'2018-01-01','2018-09-10'
exec dodaj_turniej 'Siatkarski turniej',2000,1000,500,'2018-05-01','2018-11-10'
exec dodaj_turniej 'Turniej grozy',2000,1000,500,'2018-03-01','2018-06-10'
exec dodaj_turniej 'Puchar wielkich',2000,1000,500,'2017-02-01','2019-07-10'
exec dodaj_turniej 'Maly turniej plazowy',2000,1000,500,'2018-05-06','2018-09-10'
exec dodaj_turniej 'Mini volley',2000,1000,500,'2018-06-01','2018-06-10'
exec dodaj_turniej 'Puchar na plazy',2000,1000,500,'2018-02-01','2018-07-10'
exec dodaj_turniej 'Wielki puchar dzielnicy',2000,1000,500,'2018-05-01','2018-09-10'

exec dodaj_mecz 'Puchar miasta','2018-02-01','Mistrzowie','Gracze','90033012759','Siatka',2,1,'2018-06-04'
exec dodaj_mecz 'Puchar miasta','2018-02-01','Siatkarze','Gracze','90033012759','Siatka',1,2,'2018-06-05'
exec dodaj_mecz 'Puchar miasta','2018-02-01','Mistrzowie','Siatkarze','90033012759','Plaza',1,2,'2018-06-07'
exec dodaj_mecz 'Puchar miasta','2018-02-01','Sroki','Gracze','90033012759','Siatka',2,0,'2018-06-09'
exec dodaj_mecz 'Wielki turniej','2018-05-01','Siatkarze','Gracze','90033012759','Siatka',0,2,'2018-06-05'
exec dodaj_mecz 'Wielki turniej','2018-05-01','Mistrzowie','Siatkarze','90033012759','Plaza',0,2,'2018-06-07'
exec dodaj_mecz 'Wielki turniej','2018-05-01','Mistrzowie','Gracze','76033012759','Siatka',2,1,'2018-06-08'
exec dodaj_mecz 'Wielki turniej','2018-05-01','Siatkarze','Sroki','76033012759','Siatka',1,2,'2018-07-05'
exec dodaj_mecz 'Siatkarski turniej','2018-05-01','Mistrzowie','Siatkarze','98033012789','Plaza',0,2,'2018-06-05'
exec dodaj_mecz 'Siatkarski turniej','2018-05-01','Mistrzowie','Gracze','98033012789','Siatka',2,1,'2018-06-04'
exec dodaj_mecz 'Siatkarski turniej','2018-05-01','Siatkarze','Gracze','98033012789','Wielogrod siatkarski',1,2,'2018-06-05'
exec dodaj_mecz 'Siatkarski turniej','2018-05-01','Sroki','Siatkarze','76033012759','Plaza',0,2,'2018-09-05'
exec dodaj_mecz 'Mini volley','2018-06-01','Mistrzowie','Gracze','76033012759','Siatka',2,0,'2018-06-04'
exec dodaj_mecz 'Mini volley','2018-06-01','Siatkarze','Gracze','82033012759','Siatka',1,2,'2018-06-05'
exec dodaj_mecz 'Mini volley','2018-06-01','Mistrzowie','Siatkarze','82033012759','Siatka',0,2,'2018-06-06'
exec dodaj_mecz 'Mini volley','2018-06-01','Gile','Gracze','82033012759','Wielogrod siatkarski',2,1,'2018-06-07'
exec dodaj_mecz 'Puchar na plazy','2018-02-01','Siatkarze','Gracze','82033012759','Siatka',2,0,'2018-03-05'
exec dodaj_mecz 'Puchar na plazy','2018-02-01','Mistrzowie','Siatkarze','82033012759','Siatka',0,2,'2018-03-05'
exec dodaj_mecz 'Puchar na plazy','2018-02-01','Mistrzowie','Gracze','82033012759','Wielogrod siatkarski',2,1,'2018-03-04'
exec dodaj_mecz 'Puchar na plazy','2018-02-01','Gile','Gracze','82033012759','Wielogrod siatkarski',1,2,'2018-06-05'

go
							/*Tworzenie triggerów*/
/**na insert**/

/*Podczas dodawania wyniku meczu, sprawdzenie czy nie wpisano dwóch takich samych dru¿yn bior¹cych w nim udzia³. 
Jeœli tak siê sta³o, wynik meczu nie zostanie dodany.*/
create trigger dodawanie_mecz_dwie_rozne_druzyny_sprawdzenie
on Mecz for insert
as
if exists(
	select 1
	from inserted i
	where i.druzyna_1=i.druzyna_2
)
begin
print 'Druzyna nie moza grac sama przeciwko sobie!'
rollback tran
end
go
/*Na insert,update*/

/*Przy dodawaniu zawodnika do dru¿yny lub zmienianie jego dru¿yny, 
sprawdzenie czy dru¿yna nie ma ju¿ 2 (max. iloœæ) zawodników. Jeœli ma, nie pozwoliæ na dodanie/zmianê.*/
create trigger zawodnik_do_druzyny_sprawdzenie
on Zawodnik
for insert,update
as
	select top 1 count(*) as [Ilosc],d.id, d.nazwa into #najliczniejsza
	from Druzyna d
	join inserted i
		on i.id_druzyna = d.id
	join Zawodnik z
		on z.id_druzyna = d.id
	group by d.id, d.nazwa
	order by [Ilosc] desc

if (select Ilosc from #najliczniejsza) > 2
begin
	declare @nazwa nvarchar(40)
	set @nazwa = (select nazwa from #najliczniejsza)
	print 'Druzyna '+@nazwa+' ma juz maksymalna liczbe zawodnikow!'
	rollback tran
end
go

/*Przy dodawaniu wyników meczu (wiersza do tabeli Mecz) lub zmianie rekordu w tabeli Mecz,
 sprawdzenie czy data rozegrania meczu nie jest póŸniejsza ni¿ data koñca turnieju.
  Jeœli jest, rekord nie zostanie dodany/zmieniony. */
create trigger mecz_sprawdzenie_daty
on Mecz for insert, update
as
if exists(select 1 from Mecz m
join inserted i
	on m.id = i.id
join Turniej t
	on m.id_turniej = t.id
where i.data > t.data_konca)
begin
	print 'Nie mozna dodawac meczu rozegranego po zakonczeniu turnieju!'
	rollback tran
end
go
/*Na update*/

/*Przy modyfikacji którejœ nagrody w rekordzie tabeli Turniej, 
sprawdzenie czy turniej ju¿ siê nie zacz¹³ (jeœli tak, zmiana bêdzie mo¿liwa 
tylko w przypadku zwiêkszenia nagrody).*/
create trigger edycja_nagrody_sprawdzenie
on Turniej for update
as
update Turniej set pierwsze_miejsce=d.pierwsze_miejsce
from Turniej t 
join inserted i
	on t.id = i.id
join deleted d
	on t.id = d.id
where d.pierwsze_miejsce>i.pierwsze_miejsce and (SELECT CONVERT(date, getdate()))>t.data_rozpoczecia

update Turniej set drugie_miejsce=d.drugie_miejsce
from Turniej t 
join inserted i
	on t.id = i.id
join deleted d
	on t.id = d.id
where d.drugie_miejsce>i.drugie_miejsce and (SELECT CONVERT(date, getdate()))>t.data_rozpoczecia

update Turniej set trzecie_miejsce=d.trzecie_miejsce
from Turniej t 
join inserted i
	on t.id = i.id
join deleted d
	on t.id = d.id
where d.trzecie_miejsce>i.trzecie_miejsce and (SELECT CONVERT(date, getdate()))>t.data_rozpoczecia


go

/*Przy modyfikacji sk³adu dru¿yny (zmiana id_dru¿yny w rekordzie tabeli Zawodnik), 
sprawdzenie czy dana dru¿yna bierze udzia³ w trwaj¹cym ju¿ turnieju 
(czy rozegra³a ju¿ przynajmniej jeden mecz). Jeœli tak, zmiana nie bêdzie mo¿liwa. */
create trigger edycja_skladu_druzyny_sprawdzenie
on Zawodnik for update
as
if exists(
select 1
from Zawodnik z
join inserted i
	on z.pesel = i.pesel
join deleted d
	on z.pesel = d.pesel
where i.id_druzyna!=d.id_druzyna
and exists (select 1 
		from Mecz m
		join Turniej t on m.id_turniej = t.id 
		where t.data_konca>(select convert(date,getdate())) 
		and (m.druzyna_1=d.id_druzyna or m.druzyna_2=d.id_druzyna)
		)
)
begin
print 'Nie mozna zmieniac skladu druzyny grajacej w trwajacym turnieju!'
rollback tran
end

go

/*Na delete*/

/*Przy usuwaniu turnieju, sprawdzenie czy ju¿ trwa. Jeœli tak, usuniêcie nie bêdzie mo¿liwe. */
create trigger usuwanie_turniej_sprawdzenie
on Turniej for delete
as
if exists(
	select 1 
	from deleted d
	where (select convert(date,getdate())) between d.data_rozpoczecia and d.data_konca
	)
begin
print 'Nie mozna usunac trwajacego turnieju!'
rollback tran
end
go

/*Podczas usuwania zawodnika, sprawdzenie czy jego dru¿yna nie bierze udzia³u w trwaj¹cym turnieju. 
Jeœli bierze, usuwanie siê nie powiedzie.*/
create trigger usuwanie_zawodnik_sprawdzenie
on Zawodnik for delete
as
if exists (
	select *
	from deleted d
	join Mecz m
		on d.id_druzyna=m.druzyna_1 or d.id_druzyna=m.druzyna_2
	join Turniej t
		on m.id_turniej = t.id
	where (select convert(date,getdate())) between t.data_rozpoczecia and t.data_konca
)
begin
print 'Nie mozna usunac zawodnika, ktorego druzyna bierze udzial w trwajacym turnieju!'
rollback tran 
end
go
