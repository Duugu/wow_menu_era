WICHTIGE EINRICHTUNGSSCHRITTE. GEHE FOLGENDERMAßEN VOR:
1. Kopiere den Ordner "wow menu era" aus der heruntergeladenen Zip-Datei in einen beliebigen Ordner auf deinem Computer.
2. Geh zum gerade eingefügten Ordner "wow menu era".
3. (Optional) Erstelle eine Verknüpfung zum entsprechenden Skript (wow-menu era DE EU.ahk, wow-menu era EN EU.ahk oder wow-menu era EN US.ahk, je nach deiner Kombination aus Sprache und Region) auf deinem Desktop. Damit kannst du das Skript später einfacher zum Spielen starten.
4. Geht zum Ordner "CopyTheContentOfThisFolderToInterface" in deinem "wow menu era" Ordner. Er enthält 3 Ordner.
5. Kopiere alle 3 Ordner ("DialogFrame", "GLUES", "HELPFRAME").
6. Geht zum "Interface" Ordner ("C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface").
7. Füge die soeben kopierten 3 Ordner in diesem "Interface"-Ordner ein.
8. Das war's!
Achtung: Du musst die Anweisungen oben zwingend genau befolgen. Kopiere NICHT einfach den gesamten "wow_menu"-Ordner aus der heruntergeladenen Zip-Datei in den "Interface"-Odner. Das Skript funktioniert dann nicht.

1. Was macht das Skript?

Das Skript hat zwei Modi: "Login" und "Spielen", zwischen denen du mit ALT + F1 umschalten kannst.
Im Modus "Login" kannst du über ein Audio-Menü auf der Charakterauswahl-Seite von WoW Chars auswählen und mit diesen die Spielwelt betreten, neue Chars erstellen, zu einem anderen Server wechseln oder Chars löschen.
Im Modus "Spielen" kannst du über die Taste NUMMERNBLOCK 7 einen Rechtsklick und über NUMMERNBLOCK 8 einen Linksklick an deinen Füßen ausführen. Mit NUMMERNBLOCK 9 drehst du dich zum aktuellen Beacon.
Mit ALT + ESCAPE kannst du das Skript vollständig beenden.

2. Verwendung

Du startest das Skript indem du die Datei für deine Sprache und Region ausführst:
- Wenn du auf EU-Servern in Deutsch spielst: wow-menu era DE EU.ahk
- Wenn du auf EU-Servern in English spielst: wow-menu era EN EU.ahk
- Wenn du auf US-Servern spielst: wow-menu era EN US.ahk
Das Skript startet im Modus "Login". Es wird erst aktiv, wenn du WoW gestartet hast und das WoW-Fenster den Fokus bekommt.
Dann versucht es die Charauswahlseite zu erkennen, bzw. es warte so lange, bist du in WoW angemeldet bist und die Charakterauswahlseite geladen ist. Solange das Skript irgendeine Erkennung durchführt oder wartet, hörst du einen Sound. Der Sound bedeutet, dass du warten musst.
Achtung: Drücke keine Taste, wechsel nicht das Fenster und mach keine anderen Dinge solange der Sound läuft. Niemals. Nirgendwo im Menü. Selbst dann nicht, wenn sonst die Welt untergeht. Hebe deine Hände in die Luft, solange der Sound läuft.
Sobald du auf der Charakterauswahlseite angekommen bist, öffnet sich das Audio-Menü. Es sagt "Hauptmenü". Du kannst im Menü nach rechts gehen, und die einzelnen Optionen verwenden.
Wenn du dich mit einem Char einloggen möchtest, musst du diesen erst auswählen und dich dann mit dem ausgewählen Char einloggen.
Charkternamen werden dabei nicht erkannt oder vorgelesen. Dir wird nur "1, 2, 3 bis 10" für die Charakterplätze vorgelesen. Was sich für ein Char auf dem jeweiligen Platz befindet musst du dir selbst notieren.
Neu erstellte Chars landen immer auf dem nächsten freien Platz. Wenn du also schon 3 Chars hast, und einen neuen erstellst, dann ist dieser auf Platz 4.
Nach dem Einloggen schaltet das Skript automatisch auf "Spielen". Beim Ausloggen schaltet es automatisch auf "Login". Sollte das nicht funktionieren, kannst du mit ALT + F1 selbst umschalten.

3. Voraussetzungen:

- Das Skript funktioniert nur unter Windows, nur mit WoW Ära.
- Du darfst das Skript und seinen Ordner nicht verschieben. Wenn du es einfacher starten möchtest, kannst du dir eine Verknüpfung zu deinem Skript erstellen.
- Das Skript erfordert, dass du WoW im Vollbildmodus spielst. (Das ist standardmäßig so.)
- Das Skript erfordert, dass du in WoW dieselbe Auflösung wie in Windows verwendest (das ist standardmäßig so).

----------------------------------------------------------------------------------------

Veröffentlichungshinweise:
	4.1
		- Update für Classic Ära server
	3.13
		- Bessere Social contract Erkennung.
	3.12
		- Unterstützung für automatisches Pausieren bei Dial Targeting hinzugefügt.
		- Social contract wird erneut automatisch angenommen.
	3.11
		- Versucht ein Problem mit ultra wide Bildschirmen mit einem größeren Seitenverhältnis als 1,77 zu beheben.
	3.10
		- Versucht ein Problem mit der nicht funktionierenden Autoannahme des Vertrags bei der ersten Anmeldung zu beheben. Keine Ahnung, ob das funktioniert hat, da ich es nicht testen kann.
	3.9
		- Problem mit dem EN US Skript behoben.
	3.8
		- Fehlende Sounddatei für US East Eranikus hinzugefügt.
	3.7
		- Serverliste für US und EU aktualisiert.
		- Fehlende Blutelfen wieder zur Charactererstellung hinzugefügt.
		- Serverarten hinter die Servernamen angehängt.
	3.6
		- Fehler bei der Erstellung von neuen Chats mit Klasse Magier korrigiert.
	3.5
		- US East Serverliste aktualisiert.
	3.4
		- Fixed a bug with the US EN version of the script
	3.3
		- Versucht das automatische Zustimmen zum Vertrag zu beheben. Kann ich nicht testen, da ich den Vertrag schon angenommen habe. Feedback, ob es jetzt geht, wäre gut.
		- Aktionen für numpad 7 und 8 wurden geändert:
			- numpad7: Rechtsklick vor dich (war Rechtsklick an deinen Füßen)
			- numpad8: Linksklick an deinen Füßen (für AoE Zauber, die per linksklick in die Spielwelt platziert werden müssen)

	3.2
		- Verhaltenscodes bei erster Anmeldung wird automatisch akzeptiert
		- Veraltete Addons laden wir automatisch akzeptiert
		- Shazzrah aus der Liste der englischen Server in EU entfernt
	3.1
		- Listen für US west, US east und EU Englisch mit neuen Server aktualisiert
	3.0
		- Erste Version für WotLK