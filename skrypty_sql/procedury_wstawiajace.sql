								/*Tworzenie procedur dodaj¹cych dane do tabel*/
go
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

/*Dodaje nowy rekord do tabeli Miasto.*/
create procedure dodaj_miasto
(
@nazwa nvarchar(40)
)
as
insert into Miasto values(@nazwa)
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