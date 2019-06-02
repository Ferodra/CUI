local E, L = unpack(select(2, ...)) -- Engine, Locale
local L = E:LoadModules("Locale_deDE")

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------- UNITS -------
L["player"] 		= "Spieler"
L["target"] 		= "Ziel"
L["pet"] 			= "Begleiter"
L["targettarget"] 	= "Ziel des Ziels"
L["boss"] 			= "Boss"
L["raid"] 			= "Schlachtzug"
L["party"] 			= "Gruppe"
L["focus"] 			= "Fokus"
L["focustarget"] 	= "Fokusziel"
L["unit"] 			= "Einheit"

------- MOVER HANDLES -------
-- Defines the frame names on mover handles (anchor mode)
L["frame"] 				= "fenster"
L["Frame"] 				= "Fenster"
L["playerFrame"] 		= "Spieler Fenster"
L["petFrame"] 			= "Begleiter Fenster"
L["targetFrame"] 		= "Ziel Fenster"
L["targettargetFrame"] 	= "Ziel des Ziels Fenster"
L["focusFrame"] 		= "Fokus Fenster"
L["focustargetFrame"] 	= "Fokusziel Fenster"
L["arenaFrame"] 		= "Arena Fenster"
L["partyFrame"] 		= "Gruppen Fenster"
L["bossFrame"] 			= "Boss Fenster"
L["raidFrame"] 			= "Schlachtzugsfenster"
L["raid40Frame"] 		= "40-er Schlachtzugsfenster"
L["chatFrame"]			= "Chat"
L["stanceBarFrame"]		= "Haltungsleiste"
L["actionbarFrame"]		= "Aktionsleiste"
L["tooltipAnchor"]		= "Tooltip Anker"
L["alternatePower"]		= "Klassenenergie"
L["buffs"]				= "Buffs"
L["debuffs"]			= "Debuffs"
L["micromenu"]			= "Mikromenü"
L["raidRoleFrame"]		= "Rollenübersicht"
L["vehicleSeatFrame"]	= "Fahrzeug-Sitze"

------- MISC -------
L["Misc"] 		= "Misc"
L["None"] 		= "Nichts"
L["Reset"] 		= "Zurücksetzen"
L["castbar"] 	= "Zauberleiste"
L["Health"]		= "Leben"
L["Power"]		= "Ressource"
L["AuraBars"]	= "Auren-Leisten"

L["Top"]		= "Oben"
L["Bottom"]		= "Unten"
L["Left"]		= "Links"
L["Right"]		= "Rechts"
L["Center"]		= "Mitte"
L["Up"]			= "Hoch"
L["Down"]		= "Runter"

L["TOPLEFT"] 		= "Oben Links"
L["LEFT"]		 	= "Links"
L["BOTTOMLEFT"] 	= "Unten Links"
L["TOP"] 			= "Oben"
L["CENTER"] 		= "Mitte"
L["BOTTOM"] 		= "Unten"
L["TOPRIGHT"] 		= "Oben Rechts"
L["RIGHT"] 			= "Rechts"
L["BOTTOMRIGHT"] 	= "Unten Rechts"

L["of"]			= "von"

-- POWERS
L["Modifies the color of"] = "Ändert die Farbe der Ressource"
L["MANA"]			= _G["MANA"]
L["RAGE"]			= _G["RAGE"]
L["FOCUS"]			= _G["FOCUS"]
L["ENERGY"]			= _G["ENERGY"]
L["COMBO_POINTS"]	= _G["COMBO_POINTS"]
L["RUNES"]			= _G["RUNES"]
L["RUNIC_POWER"]	= _G["RUNIC_POWER"]
L["SOUL_SHARDS"]	= _G["SOUL_SHARDS"]
L["LUNAR_POWER"]	= _G["LUNAR_POWER"]
L["HOLY_POWER"]		= _G["HOLY_POWER"]
L["MAELSTROM"]		= _G["MAELSTROM"]
L["CHI"]			= _G["CHI"]
L["INSANITY"]		= _G["INSANITY"]
L["ARCANE_CHARGES"]	= _G["ARCANE_CHARGES"]
L["FURY"]			= _G["FURY"]
L["PAIN"]			= _G["PAIN"]
L["STAGGER"]		= _G["STAGGER"]
L["RUNE_READY"]		= "Rune Bereit"
L["RUNE_NOT_READY"]	= "Rune Abklingzeit"
L["PowerHeader"]	= "Kraft/Ressourcen Farben"
L["PowerColorDesc"]	= "Diese Einstellungen erlauben es dir, die Standard Kraft/Ressourcen Farben zu ändern"

-- READYCHECK
L["ReadycheckDesc"]		= "Diese Einstellungen erlauben es dir, die Farben des Bereitschaftscheck-Symbols zu ändern"
L["Readycheck"]			= "Bereitschaftscheck"
L["ReadycheckIcons"]	= "Bereitschaftscheck Symbole"
L["ready"]				= "Bereit"										  																									   
L["notready"]			= "Nicht Bereit"
L["waiting"]			= "Ausstehend"
L["Modifies the Readycheck color for state"] = "Ändert die Farbe des Bereitschaftschecks im Zustand"
L["This will apply the next time a readycheck was performed"] = "Änderungen werden angewendet, sobald das nächste mal ein Bereitschaftscheck stattfindet."

-- COLORS
L["ColorPickerPlus"]			= "Für diese Einstellungen wird empfohlen, das AddOn \"Color Picker Plus\" zu nutzen, da es viele Vorteile gegenüber dem Standard Farbwähler bietet!"
L["ClassColors"]				= "Klassenfarben"

-- ZONE COLORS
L["ZoneColors"]		= "Zonen Farben"
L["ZoneColorsDesc"]	= "Diese Einstellungen erlauben es dir, die Farben von Zonen-Texten zu ändern"
L["Modifies the zone color"]	= "Ändert die Farbe von Zonen mit einer bestimmten PvP Einstellung"
L["arena"] 			= "Arena"
L["friendly"] 		= "Freundlich"
L["contested"] 		= "Umkämpft"
L["hostile"] 		= "Feindlich"
L["sanctuary"] 		= "Sanktum"
L["combat"] 		= "Kampf"
L["default"] 		= "Standard"

-- CLASS COLORS
L["Modifies the color of the class"] = "Ändert die Farbe der Klasse"
L["ClassColorDesc"] 			= "Diese Einstellungen erlauben es dir, die Standard Klassenfarben zu ändern"

-- REACTION COLORS
L["ReactionColor"] 				= "Gesinnungs-Farben"
L["ReactionColorDesc"]			= "Diese Einstellungen erlauben es dir, die Farben der Fraktions-Gesinnungen zu ändern"
L["Modifies the reaction color"]= "Ändert die Farbe der Gesinnungen, welche eine Fraktion dir gegenüber haben kann"
L["neutral"] 					= "Neutral"
L["unfriendly"] 				= "Unfreundlich"

-- CASTBAR COLORS
L["CastbarColorDesc"]	= "Diese Einstellungen erlauben es dir, die Farben der verschiedenen Zauberleisten-Zustände zu ändern"
L["CastbarColors"]		= "Zauberleisten Farben"
L["Modifies the Castbar color for state"]	= "Ändert die Farbe der Zauberleiste im Zustand"																																			  
L["success"]								= "Erfolgreich"
L["failed"]									= "Fehlgeschlagen"
L["interruptible"]							= "Unterbrechbar"
L["notInterruptible"]						= "Nicht Unterbrechbar"						  

-- LAYOUT COLORS
L["LayoutColorDesc"]	= "Diese Einstellungen erlauben es dir, die Farben der Layout Leisten zu ändern"
L["Modifies layout bar color"] 	= "Ändert die Farbe einer Layout Leiste"
L["XPBar"]				= "Erfahrungsleiste"
L["XPBarNormal"] 		= "Erfahrungsleiste Normal"
L["XPBarRested"] 		= "Erfahrungsleiste Erholt"
L["AzeriteBarOverlay"] 	= "Azerit Leiste Textur"
L["UseNormalClassColor"]= "Normal Klassenfarbe"
L["UseNormalClassColorDesc"]= "Nutze deine Klassenfarbe für den Normalzustand"
L["AzeriteBar"]			= "Azerit Leiste"												 

------- STATS -------
L["agility"] = "Beweglichkeit"
L["mastery"] = "Meisterschaft"
L["leech"] = "Lebensraub"
L["versatility"] = "Vielseitigkeit"
L["haste"] = "Tempo"
L["crit"] = "Kritischer Trefferwert"

------- CONFIG HEADERS -------

-- Main
L["Global"] = "Global"
L["Unitframes"] = "Einheitenfenster"
L["Actionbars"] = "Aktionsleisten"
L["Bags"] = "Taschen"
L["Camera"] = "Kamera"
L["System"] = "System"
L["Colors"] = "Farben"
L["Maps"] = "Karten"
L["Infoframes"] = "Info Fenster"
L["Tooltip"] = "Tooltip"
L["Changelog"] = "Changelog"
L["Bugtracker"] = "Bugtracker"
L["Credits"] = "Credits"
L["Help"] = "Hilfe"

-- Actionbars
L["Actionbar"] = "Aktionsleiste"
L["Stancebar"] = "Haltungsleiste"
L["Extra Button"] = "Extra Button"
L["Zone Button"] = "Zonen Button"
L["Micromenu"] = "Mikromenü"
L["Pet Bar"] = "Begleiter-Leiste"
L["Totem Bar"] = "Totem-Leiste"
L["Bar"] = "Leiste"

-- Buffs and Debuffs
L["Buffs and Debuffs"] = "Stärkungs- & Schwächungszauber"

-- Unitframes
L["All"] = "Alle"
L["Pet"] = "Begleiter"
L["Player"] = "Spieler"
L["Target"] = "Ziel"
L["TargetTarget"] = "Ziel des Ziels"
L["Focus"] = "Fokus"
L["FocusTarget"] = "Fokusziel"
L["Arena"] = "Arena"
L["Party"] = "Gruppe"
L["Raid"] = "Schlachtzug"
L["Raid40"] = "Schlachtzug 40"
L["Boss"] = "Boss"

-- Help
L["HelpWelcome"] = "Willkommen zur CUI Optionen-Dokumentation!\nWie kann ich dir helfen?"

------- CONFIG BODY -------
-- MISC
L["Enable"] 			= "Einschalten"
L["Toggle"] 			= "Umschalten"
L["Font"] 				= "Schrift"
L["Scale"] 				= "Größe"
L["Width"] 				= "Breite"
L["Height"] 			= "Höhe"
L["WidthFontDesc"]		= "Maximale Breite des Schrift-Containers. Genutzt für Horizontale Ausrichtung. Im Zweifel auf 0 belassen"
L["Visibility"]			= "Sichtbarkeit"
L["DefVisibility"]		= "Standard Sichtbarkeit"
L["DefVisibilityDesc"]	= "Falls du den Sichtbarkeits-String auf Standard zurücksetzen möchtest"
L["Position"]			= "Position"
L["Positioning"]		= "Positionierung"
L["XOffset"]			= "X Verschiebung"
L["YOffset"]			= "Y Verschiebung"
L["HAlignFontDesc"]		= "Setzt die Horizontale Wachtumsrichtung dieser Schrift. Links setzt das Wachstum nach Rechts. Rechts setzt es nach Links. Genau so wie in jedem Textverarbeitungsprogramm. Um die Schrift neu zu positionieren, nutze das Positions Dropdown. Diese Option wird von der Breite des Schrift-Containers beeinflusst"
L["FontStyle"]			= "Schrift Stil"
L["FontHeight"]			= "Schriftgröße"
L["FontType"]			= "Schriftart"
L["FontFlags"]			= "Kontur der Schriftart"
L["Fonts"]				= "Schriften"
L["FontColor"]			= "Schriftfarbe"
L["TextShadow"]			= "Schrift Schatten"
L["TextShadowColor"]	= "Schrift Schattenfarbe"
L["Style"]				= "Stil"
L["Styling"]			= "Styling"
L["Size"]				= "Größe"
L["Bars"]				= "Leisten"
L["HorizontalAlign"]	= "Horizontale Ausrichtung"
L["VerticalAlign"]		= "Vertikale Ausrichtung"
L["BorderSize"]			= "Rahmenbreite"
L["BorderColor"]		= "Rahmenfarbe"
L["Fading"]				= "Verblassen"
L["Background"]			= "Hintergrund"
L["BackgroundColor"]	= "Hintergrundfarbe"
L["PaddingH"]			= "Horizontaler Überfluss"
L["PaddingHDesc"]		= "Steuert die Menge des Horizontalen 'Überflusses' für den Hintergrund"
L["PaddingV"]			= "Vertikaler Überfluss"
L["PaddingVDesc"]		= "Steuert die Menge des Vertikalen 'Überflusses' für den Hintergrund"
L["Enabled"]			= "Eingeschaltet"
L["Disabled"]			= "Ausgeschaltet"
L["Hide in Combat"]		= "Verstecke im Kampf"
L["UseClassColor"]		= "Nutze deine Klassenfarbe"
L["UseClassColorDesc"]	= "Benutze deine Klassenfarbe statt einer spezifizierten"
L["UseUnitClassColor"]	= "Nutze Einheiten Klassenfarbe"
L["UseUnitClassColorDesc"]= "Benutze die Klassenfarbe der Einheit, statt einer spezifizierten"
L["BlendMode"]			= "Mischmodus"

-- Statistics
L["Statistics"]			= "Statistiken"
L["EnableLogging"]		= "Spielzeit Speichern"
L["RemoveCharacter"]	= "Charakter Entfernen"
L["YourPlaytime"]		= "Deine gesamte Spielzeit (Bisher)"
L["CharacterPlaytime"]	= "Deine Charakter Spielzeit"
L["PlaytimeCharacterRemoved"] = " wurde aus der Liste entfernt."

-- Frame Chooser
L["FrameChooserButton"]	= "Fenster Auswählen"
L["AttachMode"]			= "Anheften"
L["AttachToFrame"]		= "Anheften an"
L["FrameChooser1"]		= "Fenster Auswahl aktiv"
L["FrameChooser2"]		= "Linksklick um ein Fenster auszuwählen"
L["FrameChooser3"]		= "Rechtsklick um die Auswahl abzubrechen"

-- Headers [The 4 BIG Buttons]
L["Lua-Errors"] 				= "Lua-Fehler"
L["Lua-ErrorsDesc"] 			= "Wenn aktiv, werden Fehler, welche von AddOns verursacht werden, angezeigt"
L["SetKeybinds"] 				= "Tastaturbelegung"
L["SetKeybindsDesc"] 			= "Ermöglicht es, die Aktionsleisten Tastaturbelegung ganz einfach per Mouseover über den Knöpfen zu setzen!"
L["Install"] 					= "Installieren"
L["InstallDesc"] 				= "Alles Installieren"
L["Toggle Anchors"] 			= "Anker Umschalten"
L["Toggle AnchorsDesc"] 		= "Gibt verschiedene Elemente der Benutzeroberfläche frei, um sie zu bewegen."
L["Reset Anchors"] 				= "Anker Zurücksetzen"
L["Reset AnchorsDesc"] 			= "Setzt alle Anker auf ihre Standard Positionen zurück."

-- Global
L["Nameplates"] 				= "Namensplaketten"
L["Personal Nameplate"] 		= "Persönliche Namensplakette"
L["Personal Nameplate Desc"]	= "Wenn eingeschaltet, wird im Kampf die Persönliche Namensplakette unter deinem Charakter angezeigt"

-- Media
L["Media"]						= "Medien"
L["WorldSettings"]				= "Welt Einstellungen"
L["OverrideGlobalFont"]			= "Überschreibe Globale Schriftart"
L["OverrideGlobalFontDesc"]		= "Ersetzt die Globale Schriftart, welche an fast allen Stellen der Benutzeroberfläche genutzt wird."
L["OverrideWorldNameFont"]		= "Namen Überschreiben"
L["OverrideWorldDamageFont"]	= "Schaden Überschreiben"
L["OverrideWorldDefaultFont"]	= "Standard Überschreiben"
L["WorldNameFont"]				= "Namen Schriftart"
L["WorldNameFontDesc"]			= "Ändert die Schriftart, welche in der Welt für die Darstellung von Namen über Spielern, NPCs usw. genutzt wird. Das Ändern dieser Einstellung benötigt einen Relog, da ein Neuladen der Benutzeroberfläche nicht reicht.\nBitte beachte, dass nicht jede Schriftart funktioniert, da dieses Feature stark abhängig von der AddOn Lade-Reihenfolge ist. Probier am besten etwas herum"
L["WorldDamageFont"]			= "Schaden Schriftart"
L["WorldDamageFontDesc"]		= "Ändert die Schriftart, welche in der Welt für die Darstellung von Schaden und Heilung genutzt wird. Das Ändern dieser Einstellung benötigt einen Relog, da ein Neuladen der Benutzeroberfläche nicht reicht.\nBitte beachte, dass nicht jede Schriftart funktioniert, da dieses Feature stark abhängig von der AddOn Lade-Reihenfolge ist. Probier am besten etwas herum"
L["WorldDefaultFont"]			= "Standard Schriftart"
L["WorldDefaultFontDesc"]		= "Ändert die Schriftart, welche in der Welt für die Darstellung von Texten wie den Erhalt von Ehre genutzt wird. Das Ändern dieser Einstellung benötigt einen Relog, da ein Neuladen der Benutzeroberfläche nicht reicht.\nBitte beachte, dass nicht jede Schriftart funktioniert, da dieses Feature stark abhängig von der AddOn Lade-Reihenfolge ist. Probier am besten etwas herum"

-- Actionbars
L["Values"]				= "Werte"
L["ShowGrid"] 			= "Zeige leere Tasten"
L["ClickOnDown"]		= "Aktion bei Tastendruck"
L["ABTooltip"]			= "Tooltip"
L["AllWarning"]			= "ACHTUNG: Diese Einstellungen überschreiben die Schrift-Einstellungen von jeder einzelnen Aktionsleiste! Mit Vorsicht benutzen!\nFalls du irgend welche Probleme mit der Positionierung der Schriften hast, versuche die Position auf 'Unten Rechts' zu stellen"
L["BarReservedWarning"]	= "ACHTUNG: Diese Leiste ist bereits für die verschiedenen Formen von Druiden reserviert!\nLeiste 8 für unsichtbare Schurken!\nFalls du irgend welche Aktionen von dieser Leiste entfernst, oder änderst, wird dies auch deine Hauptleiste (Leiste 1) beeinflussen!\nEs wird empfohlen, diese Leiste deaktiviert zu lassen, während zu einen Druiden oder Schurken spielst!"
L["VisibilityDesc"]		= "Eine Verkettung aus Makro Regeln um zu bestimmen, ob diese Leiste angezeigt werden soll.\nEin paar mögliche Werte:"
L["VisibilityDescSec"]	= "Mehr ist zu finden auf"
L["ButtonConfig"]		= "Tasten"
L["FlyoutDirection"]	= "Ausklapprichtung"
L["FlyoutDirectionDesc"]= "Die Richtung, welche für zusammengefasste Zauber wie Magier Portale genutzt wird"
L["ButtonsPerRow"]		= "Tasten pro Zeile"
L["ButtonsPerRowDesc"]	= "Wie viele Tasten pro Zeile (Horizontal) angezeigt werden sollen. Negative Werte kehren die Richtung um"
L["ButtonCount"]		= "Tasten"
L["ButtonCountDesc"]	= "Die Anzahl der Tasten, welche diese Leiste beinhalten  soll"
L["ButtonSize"]			= "Größe der Tasten"
L["ButtonSizeDesc"]		= "Ein Multiplikator für die Größe der einzelnen Tasten"
L["ButtonGap"]			= "Abstand der Tasten"
L["ButtonGapDesc"]		= "Der Abstand zwischen den einzelnen Tasten"
L["InCombat"]			= "Im Kampf"
L["InCombatBarFadeDesc"] = "Steuert, wie die Leiste im Kampf reagiert.\n\nBei 'Einblenden' wird der Inaktive Alpha außerhalb des Kampfes genutzt.\nBei 'Ausblenden' wird der Aktive Alpha außerhalb des Kampfes genutzt.\n\nUm nur den Mouseover zu nutzen, setze dies auf 'Nichts unternehmen'."
L["FadeIn"]				= "Einblenden"
L["FadeOut"]			= "Ausblenden"
L["DoNothing"]			= "Nichts unternehmen"
L["Mouseover"]			= "Mouseover"
L["MouseoverDesc"]		= "Beim einschalten dieser Option, wird die Aktionsleiste verblassen, außer die Maus wird darüber bewegt"
L["AlphaActive"]		= "Aktiver Alpha"
L["AlphaActiveDesc"]	= "Der Alpha(Transparenz) Wert, welcher genutzt wird wenn die Maus über der Leiste ist"
L["AlphaInactive"]		= "Inaktiver Alpha"
L["AlphaInactiveDesc"]	= "Der Alpha(Transparenz) Wert, welcher genutzt wird, wenn die Maus NICHT über der Leiste ist"
L["FadeInTime"]			= "Einblendzeit"
L["FadeInTimeDesc"]		= "Die Zeit in Sekunden um die Leiste einzublenden"
L["FadeOutTime"]		= "Ausblendzeit"
L["FadeOutTimeDesc"]	= "Die Zeit in Sekunden um die Leiste auszublenden"
L["ButtonBorderTexture"]= "Tasten Rahmen Textur"
L["NormalColor"]		= "Normale Farbe"
L["ButtonNormalTexture"]= "Tasten Normal Textur"
L["HighlightColor"]		= "Highlight Farbe"
L["ButtonHTexture"]		= "Tasten Highlight Textur"
L["PushedColor"]		= "Gedrückte Farbe"
L["ButtonPTexture"]		= "Tasten Gedrückt Farbe"
L["AdditionalAddOns"]	= "Zusätzliche AddOns"
L["UseMasque"]			= "Nutze Masque"
L["UseMasqueDesc"]		= "Wenn aktiv, wird das Aussehen der Knöpfe von Masque übernommen (sofern installiert und aktiviert)"
L["GlobalFunctions"]	= "Globale Funktionen"
L["ClearAllSlots"]		= "Leere alle Aktionsslots"
L["ClearAllSlotsDesc"]	= "Diese Aktion leert sprichwörtlich ALLE Leisten. Es wird kein einziger Zauber, kein einziges Makro, Reittier oder Haustier auf ihnen zurückbleiben. Nutze diese Aktion mit Vorsicht, da sie nicht rückgängig gemacht werden kann!"
L["Hotkey"]				= "Tastaturkürzel"
L["Cooldown"]			= "Abklingzeit"
L["Count"]				= "Anzahl"
L["Macro"]				= "Makro"

-- Bags
L["Bags"]				= "Taschen"
L["General"]			= "Generell"
L["Utility"]			= "Funktionen"
L["Autosell Greys"]				= "Graue Gegenstände verkaufen"
L["When enabled, grey items from your bag will automatically be sold"] = "Wenn eingeschaltet, werden graue Gegenstände automatisch verkauft, sobald ein Händer-Dialog geöffnet wird"
L["Autosell Greys Report"]		= "Verkaufsbericht"
L["Reports what has been sold and how much revenue you earned"] = "Berichtet, was verkauft und wie viel Umsatz erzielt wurde"
L["Sold: %s for %s"]			= "Verkauft: %s für %s"
L["Total Revenue: %s"]			= "Gesamtumsatz: %s"

-- Dataframes
L["RaidRoles"]			= "Schlachtzugsrollen"
L["RaidControl"]		= "Schlachtzugs-Kontrolle"
L["MirrorTimer"]		= "Spiegelleiste"
L["ClickThrough"]		= "Hindurchklicken"
L["Sending Pulltimer to BigWigs and DBM Users"] = "Sende Pulltimer an BigWigs und DBM-Nutzer"
L["Pull Time must be above 0 seconds!"]	= "Pull-Zeit muss über 0 Sekunden liegen!"

-- Aura Bars
L["Number of Bars"]		= "Anzahl der Leisten"

-- Maps
L["Map"] 				= "Karte"
L["Worldmap"] 			= "Weltkarte"
L["Minimap"] 			= "Minikarte"
L["Coordinates"] 		= "Koordinaten"

-- Engine
L["Camera"]			= "Kamera"
L["CameraDesc"]		= "Diese Einstellungen sind für Monitore mit einem hohen DPI-Wert, oder hohe Auflösungen im generellen gedacht, da die Standard Kamera Einstellungen nicht sehr brauchbar für diese sind. Um den Blizzard Standard zu nutzen, setze einen oder beide Werte auf 0"
L["CameraDescSec"]	= "nachdem ein Wert auf 0 gesetzt wurde, wird ein Neuladen der Benutzeroberfläche erfordert!"
L["YawSpeed"]		= "Giergeschwindigkeit"
L["YawSpeedDesc"]	= "Ändert die Giergeschwindigkeit (Links/Rechts) der Kamera\nAuf 0 setzen und /reload nutzen um den Standard zu nutzen"
L["PitchSpeed"]		= "Neigungsgeschwindigkeit"
L["PitchSpeedDesc"]	= "Ändert die Neigungsgeschwindigkeit (Hoch/Runter) der Kamera\nAuf 0 setzen und /reload nutzen um den Standard zu nutzen"
L["Presets"]		= "Vorlagen"
L["PresetFullHD"]	= "1080p (Full HD)"
L["Preset4K"]		= "4K (Ultra HD)"
L["Actioncam"]		= "Actioncam"
L["ActioncamDesc"]	= "Diese Einstellungen ermöglichen eine Basis Funktionalität der Actioncam. Falls du mehr Optionen haben möchtest, wird dazu geraten, Die unteren Optionen zu deaktivieren, beide Schieberegler auf 0 zu belassen und das AddOn 'DynamicCam' dafür zu nutzen!"
L["HideNotification"]		= "Benachrichtigung Verstecken"
L["HideNotificationDesc"]	= "Wenn aktiv, wird die Actioncam Warnung beim Login versteckt"
L["HeadTracking"]			= "Kopfverfolgung"
L["HeadTrackingDesc"]		= "Steuert, wie sehr die Kamera von Kopfbewegungen des Charakters beeinflusst wird"
L["ShoulderOffset"]			= "Schulterversatz"
L["ShoulderOffsetDesc"]		= "Steuert, wie sehr die Kamera nach Links/Rechts verschoben wird"
L["DynamicPitch"]			= "Dynamische Neigung"
L["DynamicPitchDesc"]		= "Überlässt der Actioncam die Steuerung der Kameraneigung. Dies resultiert darin, dass der Charakter weiter unten im Bild ist und ermöglicht ein besseres Sichtfeld nach vorne"
L["BaseFoVPad"]			= "Basis Sichtfeld"
L["BaseFoVPadDesc"]		= "Steuert, wie sehr die Kamera nach Oben/Unten geneigt wird"
L["FlyingFoVPad"]		= "Sichtfeld bei Flug"
L["FlyingFoVPadDesc"]	= "Steuert, wie sehr die Kamera nach Oben/Unten geneigt wird, wenn man am Fliegen ist"
L["EnemyFocus"]			= "Verfolge Feind"
L["EnemyFocusDesc"]		= "Lässt die Kamera angreifbare Ziele verfolgen"
L["FriendlyFocus"]		= "Verfolge Freunde"
L["FriendlyFocusDesc"]	= "Lässt die Kamera befreundete Ziele verfolgen, solange eine Form von Dialog geöffnet ist"
L["FocusPitch"]			= "Verfolgung Neigungsstärke"
L["FocusPitchDesc"]		= "Steuert, wie sehr die Neigung (Hoch/Runter) der Kamera vom Ziel beeinflusst wird"
L["FocusYaw"]			= "Verfolgung Gierstärke"
L["FocusYawDesc"]		= "Steuert, wie sehr die Gier (Links/Rechts) der Kamera vom Ziel beeinflusst wird"

-- Unitframes
L["Health"]				= "Leben"
L["Power"]				= "Kraft"
L["Health Bar"]			= "Lebensleiste"
L["Power Bar"]			= "Kraftleiste"
L["Level"]				= "Level"
L["Name"]				= "Name"
L["Time"]				= "Zeit"
L["Castbar"]			= "Zauberleiste"
L["Combat Indicator"]	= "Kampf-Indikator"
L["Alternate Power"]	= "Klassenenergie"
L["Absorption"]			= "Absorption"
L["Res Indicator"]		= "Wiederbelebungssymbol"
L["Summon Icon"]		= "Beschwörungssymbol"
L["Ready Check"]		= "Bereitschaftscheck"
L["Role Icon"]			= "Rollensymbol"
L["Leader Icon"]		= "Gruppenleitersymbol"
L["Target Icon"]		= "Zielmarkierung"
L["Aura Bars"]			= "Auren Leisten"
L["Buffs"]				= "Stärkungszauber"
L["Debuffs"]			= "Schwächungszauber"
L["Portrait"]			= "Portrait"
L["Icon"]				= "Symbol"
L["Auras"]				= "Auren"
L["NotOnMaxlevel"]		= "Nicht bei Maximallevel"
L["Color By Value"]		= "Nach Wert einfärben"

-- Armory
L["Armory Itemlevel"]				= "Zeige Gegenstandsstufe"
L["Armory Itemlevel Desc"]			= "Wenn eingeschaltet, wird die Gegenstandsstufe deiner Ausrüstung für jedes angelegte Item angezeigt."
L["Armory Class BG"]				= "Benutze Klassenhintergrund"
L["Armory Class BG Desc"]			= "Wenn eingeschaltet, wird der Standard-Hintergrund des Charakterfensters durch den Klassenhintergrund der Anprobe überschrieben."

-- Notifications
L["Reload"] 				= "Neu Laden"
L["Later"] 					= "Später"
L["Nofification_Reload"] 	= "Die vorgenommenen Änderungen erfordern ein Neuladen der Benutzeroberfläche, um vollständig wirksam zu werden!"
L["NewVersion"]				= "Eine neue Version ist verfügbar! ['%s' vom %s, Revision: %s]"

-- Credits
L["CREDITS_DEVELOPEDBY"]	= "Entwickelt von Arenima @ Alleria EU"
L["CREDITS_CUIDESC"]		= "CUI ist ein hoch modifizierbares Benutzerinterface, entwickelt um in jeder Hinsicht dir zu gehören. [Irgendwann in der Zukunft]"
L["CREDITS_THANKSTO"]		= "Ein großes Dankeschön an:\n-Runorios @ Alleria EU\n-Telendriel/Myralin @ Alleria EU\n\nIhr seid spitze!"





--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

E:AddModule("Locale_deDE", L)