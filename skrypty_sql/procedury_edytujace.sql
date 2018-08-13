					/*Tworzenie procedur edytuj¹cych rekordy w tabelach*/

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