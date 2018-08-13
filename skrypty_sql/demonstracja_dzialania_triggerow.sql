							/*Demonstracja dzialania triggerow*/

/* Dzialanie triggera dodawanie_mecz_dwie_rozne_druzyny_sprawdzenie*/
select * from Mecz
exec dodaj_mecz 'Puchar miasta','2018-02-01','Gracze','Gracze','98033012789','Siatka',2,1,'2018-06-04'
select * from Mecz
/*Koniec dzialania*/

/*Dzialanie triggera zawodnik_do_druzyny_sprawdzenie*/
exec dodaj_druzyna 'Warszawa','Siatkarze'
exec dodaj_zawodnik '82212134544','Siatkarze','Hubert','Gacek'
exec dodaj_zawodnik '82212134555','Siatkarze','Olek','Damianowy'
exec dodaj_zawodnik '82212134567','Siatkarze','Iwo','Zadanie'
select *
from Druzyna d
join Zawodnik z
	on d.id=z.id_druzyna
where d.nazwa='Siatkarze'
/*koniec dzialania*/

/*Dzialanie triggera mecz_sprawdzenie_daty*/
select * from Turniej where nazwa='Mini puchar'
exec dodaj_mecz 'Mini puchar','2017-06-01','Mistrzowie','Siatkarze','98033012789','Siatka',1,2,'2019-05-11'
select * from Mecz
/*koniec dzialania*/

/*Dzialanie triggera edycja_nagrody_sprawdzenie*/
exec dodaj_turniej 'Puchar burmistrzy',2000,1000,500,'2017-02-01','2018-07-10'
exec edytuj_turniej @nazwa='Puchar burmistrzy', @poprzednia_data_rozpoczecia='2017-02-01',@nagroda_1=1100
select * from Turniej where nazwa='Puchar burmistrzy'
/*koniec dzialania*/

/*Dzialanie triggera edycja_skladu_druzyny_sprawdzenie*/
exec dodaj_turniej 'Puchar sprawdzajacy',2000,1000,500,'2016-02-01','2019-07-10'
exec dodaj_druzyna 'Bialystok','Sprawdzacze'
exec dodaj_druzyna 'Bialystok','Przenoszeni'
exec dodaj_zawodnik '99882234567','Sprawdzacze','Adam','Sprawdzacz'
exec dodaj_zawodnik '98782234567','Sprawdzacze','Sebastian','Sprawdzacz'
exec dodaj_mecz 'Puchar sprawdzajacy','2016-02-01','Sprawdzacze','Gracze', '98033012789','siatka',2,1,'2018-06-05'
exec edytuj_zawodnik '98782234567',@nazwa_druzyny='Przenoszeni'

select * from Druzyna d
join Zawodnik z on d.id=z.id_druzyna where z.pesel='98782234567'

select * from Mecz m
join Turniej t
	on m.id_turniej=t.id
where t.nazwa='Puchar sprawdzajacy'
/*Koniec dzialania*/

/* Dzialanie triggera usuwanie_turniej_sprawdzenie*/
exec dodaj_turniej 'Turniej usuwania',2000,1000,500,'2016-01-01','2019-07-10' /*trwa*/
delete from Turniej where nazwa='Turniej usuwania' and  data_rozpoczecia='2016-01-01'
select * from Turniej where nazwa='Turniej usuwania'
/*Koniec dzialania*/

/*Dzialanie triggera usuwanie_zawodnik_sprawdzenie*/
exec dodaj_druzyna 'Warszawa','Trawa'
exec dodaj_zawodnik '11111134567','Trawa','Antoni','Trwacz'
exec dodaj_zawodnik '11111134000','Trawa','Witold','Trwacz'
exec dodaj_turniej 'Puchar trwajacy',2000,1000,500,'2016-02-01','2019-07-10'
exec dodaj_mecz 'Puchar trwajacy','2016-02-01','Trawa','Gracze', '98033012789','siatka',2,1,'2018-06-05'
delete from Zawodnik where pesel='11111134567'

select * from Zawodnik where pesel='11111134567'
/*Koniec dzialania*/














