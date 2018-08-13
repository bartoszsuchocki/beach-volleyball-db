							/*Demonstracja dzialania procedur*/

/*Dzialanie procedury dodaj_turniej*/
exec dodaj_turniej 'Turniej pokazowy',1200,1000,800,'2018-06-07','2018-08-08'
select * from Turniej where nazwa = 'Turniej pokazowy'
/*koniec dzialania*/

/*Dzialanie procedury edytuj_turniej*/
exec dodaj_turniej 'Edycyjny',1200,1000,800,'2018-06-07','2018-08-08'
exec edytuj_turniej 'Edycyjny','2018-06-07',@nagroda_1=5000
select * from Turniej where nazwa='Edycyjny'
/*koniec dzialania*/

/*Dzialanie procedury dodaj_miasto*/
 exec dodaj_miasto 'Konstantynopol'
 select * from Miasto where nazwa like 'Konst%'
/*koniec dzialania*/

/*Dzialanie procedury edytuj_miasto*/
 exec edytuj_miasto 1,'Warta'
 select * from Miasto where id=1
 exec edytuj_miasto 1,'Warszawa'
/*koniec dzialania*/

/*Dzialanie procedury dodaj_sedzia*/
 exec dodaj_sedzia '99999999978','Warszawa','Jacek','Dodawany','2018-06-05',3
 select * from Sedzia where nazwisko='Dodawany'
/*koniec dzialania*/

/*Dzialanie procedury edytuj_sedzia*/
 exec dodaj_sedzia '99999999999','Warszawa','Jacek','Edytowany','2018-06-05',2
 exec edytuj_sedzia '99999999999',@nazwisko='Zmieniony',@klasa=2
 select * from Sedzia where pesel='99999999999'
/*koniec dzialania*/

/*Dzialanie procedury dodaj_boisko*/
exec dodaj_boisko 'Warszawa','Boisko dodawane'
select * from Boisko b
join Miasto m
	on b.id_miasto = m.id
where m.nazwa='Warszawa'
/*koniec dzialania*/

/*Dzialanie procedury edytuj_boisko*/
exec dodaj_boisko 'Warszawa','Boisko edytowane'
exec edytuj_boisko 'Boisko edytowane','Wroclaw'
select * from Boisko b
join Miasto m
	on b.id_miasto = m.id
where m.nazwa='Wroclaw'
/*koniec dzialania*/

/*Dzialanie procedury dodaj_druzyna*/
exec dodaj_druzyna 'Warszawa','Dodawaczee'
select * from Druzyna where nazwa like 'Dod%'
/*koniec dzialania*/

/*Dzialanie procedury dodaj_druzyna*/
exec dodaj_druzyna 'Warszawa','Edycyjni'
exec edytuj_druzyna 'Edycyjni','Wroclaw'
select * from Druzyna d 
join Miasto m 
	on d.id_miasto = m.id 
where d.nazwa='Edycyjni'
/*koniec dzialania*/

/*Dzialanie procedury dodaj_zawodnik*/
exec dodaj_zawodnik '98762400000',null,'Arkadiusz','Milik'
select * from Zawodnik where imie='Arkadiusz'
/*koniec dzialania*/

/*Dzialanie procedury edytuj_zawodnik*/
exec dodaj_zawodnik '98762400111',null,'Arkadiusz','Edytowany'
exec edytuj_zawodnik '98762400111',@nazwisko='Edycja zakonczona'
select * from Zawodnik where pesel='98762400111'
/*koniec dzialania*/

/*Dzialanie procedury dodaj_mecz*/
exec dodaj_turniej 'zawody dodawania',100,50,10,'2018-01-01','2019-09-09'
exec dodaj_mecz 'zawody dodawania','2018-01-01','gracze',
'mistrzowie','98033012789','siatka',2,1,'2018-06-08'
select m.* from Mecz m
join Turniej t
	on m.id_turniej = t.id	
where t.nazwa='zawody dodawania'
/*koniec dzialania*/

/*Dzialanie procedury edytuj_mecz*/
exec dodaj_turniej 'zawody edytowania',100,50,10,'2018-01-01','2019-09-09'
exec dodaj_mecz 'zawody edytowania','2018-01-01','gracze',
'mistrzowie','98033012789','siatka',2,1,'2018-06-08'
declare @id int
set @id = (select count(*)from Mecz m)
exec edytuj_mecz @id_meczu=@id,@nazwa_boisko='Plazowa mekka' 
select m.*, b.nazwa as [nazwa boiska] from Mecz m
join Turniej t
	on m.id_turniej = t.id	
join Boisko b
	on m.id_boisko = b.id
where t.nazwa='zawody edytowania'
/*koniec dzialania*/

/*Dzialanie procedury dodaj_mecz_sedzia*/
exec dodaj_turniej 'zawody dublowania',100,50,10,'2018-01-01','2019-09-09'
exec dodaj_mecz_sedzia 'zawody dublowania','2018-01-01','gracze',
'mistrzowie','44886578923','Warszawa','Jakub','Adamski','2015-09-04',1,'siatka',2,1,'2018-06-08'
select * from Mecz m
join Turniej t
	on m.id_turniej = t.id
join Sedzia s
	on m.id_sedzia = s.pesel
where t.nazwa = 'zawody dublowania'

select * from Sedzia where pesel='44886578923'
/*koniec dzialania*/

/*Dzialanie procedury dodaj_druzyna_zawodnicy*/
exec dodaj_druzyna_zawodnicy 'nowa druzyna',
'Warszawa','21234234256', 'Antoni','Slad','21234234250','Bartosz','Rewir'
select *
from Druzyna d
join Zawodnik z
	on z.id_druzyna = d.id
where d.nazwa = 'nowa druzyna'
/*koniec dzialania*/

