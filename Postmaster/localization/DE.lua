-- German strings
local strings = {
    ["SI_PM_SHORT_PREFIX"]                       = "Kurzes Präfix für Nachrichten",
    ["SI_PM_SHORT_PREFIX_TOOLTIP"]               = "Wenn aktiviert, wird bei alle Chat-Nachrichten [PM] anstelle von [Postmaster] vorangestellt.",
    ["SI_PM_CHAT_MESSAGES"]                      = "Chatnachrichten",
    ["SI_PM_PREFIX_HEADER"]                      = "Präfix",
    ["SI_PM_COLORED_PREFIX"]                     = "Verwenden die Unboxer 3.8 Präfix Farbe",
    ["SI_PM_COLORED_PREFIX_TOOLTIP"]             = { "Bewirkt, dass das Präfix für Chat-Nachrichten die blauen Farben von Unboxer 2 (d. H. <<1>>|r oder <<2>>|r) anstelle der Einstellung für die Chat-Nachrichten Farbe verwendet.", SI_PM_PREFIX_COLOR, SI_PM_PREFIX_SHORT_COLOR },
    ["SI_PM_CHAT_USE_SYSTEM_COLOR"]              = "Dieselbe Farbe wie Systemnachrichten verwenden.",
    ["SI_PM_CHAT_COLOR"]                         = "Chat-Nachrichten Farbe",
    ["SI_PM_DELETE_DIALOG_SUPPRESS"]             = "Löschbestätigung unterdrücken",
    ["SI_PM_DELETE_DIALOG_SUPPRESS_TOOLTIP"]     = "Die Nachricht wird ohne Bestätigung sofort gelöscht.",
    ["SI_PM_RETURN_DIALOG_SUPPRESS"]             = "Rücksendebestätigung unterdrücken",
    ["SI_PM_BOUNCE"]                             = "Automatische Nachrichten Rücksendung",
    ["SI_PM_BOUNCE_TOOLTIP"]                     = "Sendet automatisch Nachrichten an den Absender zurück, wenn der Betreff einen der folgenden Begriffe beinhaltet: RETURN, BOUNCE, RTS",
    ["SI_PM_BOUNCE_MESSAGE"]                     = { "Nachricht an <<1>> zurücksenden", POSTMASTER_STRING_NO_FORMAT },
    ["SI_PM_WYKKYD_MAILBOX_RETURN_WARNING"]      = "Wykkyd Mailbox Rücksendung ist aktiviert",
    ["SI_PM_WYKKYD_MAILBOX_DETECTED_WARNING"]    = "Wykkyd Mailbox wurde gefunden. Bitte beachte, dass 'Automatische Nachrichten Rücksendung' |cFF0000deaktiviert|r ist, solange die Wykkyd Mailbox Rücksendung aktiv ist.",
    ["SI_PM_RESERVED_SLOTS"]                     = "Freie Inventarplätze",
    ["SI_PM_RESERVED_SLOTS_TOOLTIP"]             = "Beim Ausführen von <<1>> wird dieser Wert als freier Inventarplatz freigehalten.",
    ["SI_PM_SYSTEM"]                             = "Systemnachrichten",
    ["SI_PM_SYSTEM_TAKE_ATTACHED"]               = "Systemnachrichten mit Anhang",
    ["SI_PM_SYSTEM_DELETE_ATTACHED"]             = "Löschen von Systemnachrichten mit Anhang",
    ["SI_PM_SYSTEM_TAKE_ATTACHED_TOOLTIP"]       = "<<1>> entnimmt alle Anhänge von Systemnachrichten und löscht dann optional anschliessend die Nachricht, inklusive PvP- und Handwerksnachrichten.",
    ["SI_PM_SYSTEM_TAKE_ATTACHED_TOOLTIP_QUICK"] = { "<<1>> entnimmt alle Anhänge von Systemnachrichten und löscht anschliessend die Nachricht, inklusive PvP- und Handwerksnachrichten.", SI_PM_TAKE },
    ["SI_PM_SYSTEM_TAKE_PVP"]                    = "Allianzkrieg Belohnungen / Schlachtfelder / PvP",
    ["SI_PM_SYSTEM_TAKE_CRAFTING"]               = "Handwerksnachrichten",
    ["SI_PM_SYSTEM_TAKE_UNDAUNTED"]              = "Unerschrockene",
    ["SI_PM_SYSTEM_TAKE_OTHER"]                  = "Alle andere Systemnachrichten mit Anhang",
    ["SI_PM_SYSTEM_DELETE_EMPTY"]                = "Systemnachricht ohne Anhang",
    ["SI_PM_SYSTEM_DELETE_EMPTY_TOOLTIP_QUICK"]  = { "<<1>> lösche alle Systemnachrichten ohne Anhang, z.B. Gegenstand zur Sammlung hinzugefügt.", SI_PM_TAKE },
    ["SI_PM_SYSTEM_DELETE_EMPTY_FILTER"]         = "Systemnachricht ohne Anhang filtern",
    ["SI_PM_SYSTEM_DELETE_EMPTY_FILTER_TOOLTIP"] = { "<<1>> wird nur die entsprechenden leeren Systemnachrichten löschen, mit den eingetragenen Werten. <<2>>", SI_PM_TAKE_ALL, "SI_PM_SEPARATOR_HINT" },
    ["SI_PM_SYSTEM_DELETE_EMPTY_FILTER_TOOLTIP_QUICK"] = { "<<1>> wird nur die entsprechenden leeren Systemnachrichten löschen, mit den eingetragenen Werten. <<2>>", SI_PM_TAKE, "SI_PM_SEPARATOR_HINT" },
    ["SI_PM_PLAYER"]                             = "Spielernachrichten",
    ["SI_PM_PLAYER_TAKE_ATTACHED"]               = "Spielernachrichten mit Anhang",
    ["SI_PM_PLAYER_TAKE_ATTACHED_TOOLTIP"]       = "<<1>> entnimmt alle Anhänge von Spielernachrichten und löscht dann optional anschliessend die Nachricht, ohne Nachnahme Nachrichten.",
    ["SI_PM_PLAYER_TAKE_ATTACHED_TOOLTIP_QUICK"] = { "<<1>> entnimmt alle Anhänge von Spielernachrichten und löscht anschliessend die Nachricht, ohne Nachnahme Nachrichten.", SI_PM_TAKE },
    ["SI_PM_PLAYER_TAKE_RETURNED"]               = "Zurückgesendete Nachrichten",
    ["SI_PM_PLAYER_TAKE_RETURNED_TOOLTIP"]       = "Wenn diese Option aktiviert ist wird <<1>> die Anhänge von jeder an dich zurückgeschickten Spielernachricht entnehmen und dann optional die Nachricht löschen.",
    ["SI_PM_PLAYER_TAKE_RETURNED_TOOLTIP_QUICK"] = { "Wenn diese Option aktiviert ist wird <<1>> die Anhänge von jeder an dich zurückgeschickten Spielernachricht entnehmen und die Nachricht löschen.", SI_PM_TAKE },
    ["SI_PM_PLAYER_DELETE_EMPTY"]                = "Spielernachricht ohne Anhang",
    ["SI_PM_PLAYER_DELETE_EMPTY_TOOLTIP"]        = "<<1>> löscht alle leeren Spielernachrichten.",
    ["SI_PM_PLAYER_DELETE_EMPTY_TOOLTIP_QUICK"]  = { "<<1>> löscht alle leeren Spielernachrichten.", SI_PM_TAKE },
    ["SI_PM_PLAYER_DELETE_EMPTY_FILTER"]         = "Spielernachrichten ohne Anhang filtern",
    ["SI_PM_PLAYER_DELETE_EMPTY_FILTER_TOOLTIP"] = { "<<1>> wird nur die entsprechenden leeren Spielernachrichten löschen, mit den eingetragenen Werten. <<2>>", SI_PM_TAKE_ALL, "SI_PM_SEPARATOR_HINT" },
    ["SI_PM_PLAYER_DELETE_EMPTY_FILTER_TOOLTIP_QUICK"] = { "<<1>> wird nur die entsprechenden leeren Spielernachrichten löschen, mit den eingetragenen Werten. <<2>>", SI_PM_TAKE, "SI_PM_SEPARATOR_HINT" },
    ["SI_PM_COD"]                                = { "<<1>> Nachricht", SI_MAIL_SEND_COD },
    ["SI_PM_COD_TOOLTIP"]                        = { "<<1>> entnimmt <<2>> mit den folgenden Kriterien.", SI_MAIL_SEND_COD },
    ["SI_PM_COD_LIMIT_TOOLTIP"]                  = { "Nur Nachrichten mit <<1>> mit einem geringenen Wert als ausgewählt werden automatisch bezahlt. (ohne Limit = 0)", SI_MAIL_SEND_COD },
    ["SI_PM_MASTER_MERCHANT_WARNING"]            = "Master Merchant ist nicht aktiviert",
    ["SI_PM_COD_MM_DEAL_0"]                      = "überteuert",
    ["SI_PM_COD_MM_DEAL_1"]                      = "ok",
    ["SI_PM_COD_MM_DEAL_2"]                      = "angemessen",
    ["SI_PM_COD_MM_DEAL_3"]                      = "gut",
    ["SI_PM_COD_MM_DEAL_4"]                      = "sehr gut",
    ["SI_PM_COD_MM_DEAL_5"]                      = "kauf es!",
    
    ["SI_PM_COD_MM_MIN_DEAL_TOOLTIP"]            = { "Analysiert die Anhänge einer <<1>> mit dem Wert von Master Merchant und bezahlt diese nur, wenn alle Anhänge einen mindest genau so guten Deal haben wie diese Einstellung. (ohne Limit = 'überteuert')", SI_MAIL_SEND_COD },
    ["SI_PM_COD_MM_NO_DATA"]                     = { "<<1>> ohne Master Merchant", SI_MAIL_SEND_COD },
    ["SI_PM_COD_MM_NO_DATA_TOOLTIP"]             = { "<<1>> entnimmt <<2>> Anhänge auch ohne Master Merchant Preise", SI_PM_TAKE_ALL, SI_MAIL_SEND_COD }, 
    ["SI_PM_COD_MM_NO_DATA_TOOLTIP_QUICK"]       = { "<<1>> entnimmt <<2>> Anhänge auch ohne Master Merchant Preise", SI_PM_TAKE, SI_MAIL_SEND_COD }, 
    ["SI_PM_HELP_01"]                            = "Verwende im Chatfenster den Slash-Befehl |cFF00FF/pm|r oder |cFF00FF/postmaster|r um in diese Einstellungen zu gelangen.",
    ["SI_PM_HELP_02"]                            = { "Um <<1>> zu nutzen, öffnest du deinen Posteingang.", SI_PM_NAME },
    ["SI_PM_HELP_03"]                            = { "Mit der Taste <<1>> wird bei der ausgewählten Nachricht alle Anhänge entnommen und die Nachricht anschliessend gelöscht.", SI_PM_TAKE },
    ["SI_PM_HELP_04"]                            = "Mit der Taste <<1>> werden die Anhänge aller Nachrichten entnommen und die Nachrichten anschliessend gelöscht.",
    ["SI_PM_CRAFT_BLACKSMITH"]                   = "Schmiedematerial",
    ["SI_PM_CRAFT_CLOTHIER"]                     = "Schneidermaterial",
    ["SI_PM_CRAFT_ENCHANTER"]                    = "Verzauberermaterial",
    ["SI_PM_CRAFT_PROVISIONER"]                  = "Versorgerzutaten",
    ["SI_PM_CRAFT_WOODWORKER"]                   = "Schreinermaterial",
    ["SI_PM_GUILD_STORE_CANCELED"]               = "Verkauf abgebrochen",
    ["SI_PM_GUILD_STORE_EXPIRED"]                = "Angebot ausgelaufen",
    ["SI_PM_GUILD_STORE_PURCHASED"]              = "Gegenstand gekauft",
    ["SI_PM_GUILD_STORE_SOLD"]                   = "Gegenstand verkauft",
    ["SI_PM_PVP_FOR_THE_WORTHY"]                 = "Gerechter Lohn!",
    ["SI_PM_PVP_THANKS"]                         = "Wir danken Euch, Krieger",
    ["SI_PM_PVP_FOR_THE_ALLIANCE_1"]             = "Für das Dominion!",
    ["SI_PM_PVP_FOR_THE_ALLIANCE_2"]             = "Für den Pakt!",
    ["SI_PM_PVP_FOR_THE_ALLIANCE_3"]             = "Für das Bündnis!",
    ["SI_PM_PVP_THE_ALLIANCE_THANKS_1"]          = "Das Dominion dankt Euch",
    ["SI_PM_PVP_THE_ALLIANCE_THANKS_2"]          = "Der Pakt dankt Euch",
    ["SI_PM_PVP_THE_ALLIANCE_THANKS_3"]          = "Das Bündnis dankt Euch",
    ["SI_PM_PVP_LOYALTY"]                        = "Für Eure Kampagnentreue",
    ["SI_PM_UNDAUNTED_NPC_NORMAL"]               = "Maj al-Ragath",
    ["SI_PM_UNDAUNTED_NPC_VET"]                  = "Glirion der Rotbart", 
    ["SI_PM_UNDAUNTED_NPC_TRIAL_1"]              = "Turuk Rotkrollen",
    ["SI_PM_UNDAUNTED_NPC_TRIAL_2"]              = "Kailstig der Axt",
    ["SI_PM_UNDAUNTED_NPC_TRIAL_3"]              = "Mächtige Mordra",
    ["SI_PM_BATTLEGROUNDS_NPC"]                  = "Kampfmeister Rivyn",
    ["SI_PM_DELETE_FAILED"]                      = "Beim Löschen der Nachricht trat ein Fehler auf. Bitte versuche es erneut.",
    ["SI_PM_TAKE_ATTACHMENTS_FAILED"]            = "Beim Entnehmen der Anhänge trat ein Fehler auf. Bitte versuche es erneut.",
    ["SI_PM_READ_FAILED"]                        = "Beim Öffnen der nächsten Nachricht trat ein Fehler auf. Bitte versuche es erneut.",
    ["SI_PM_MESSAGE"]                            = "Nachricht^f",
    ["SI_PM_KEYBOARD"]                           = " (Tastaturmodus)",
    ["SI_PM_KEYBIND_ENABLE_TOOLTIP"]             = { "Aktiviert die Postmaster-Tastenbelegung: <<1>> und <<2>>", SI_LOOT_TAKE, SI_LOOT_TAKE_ALL },
    ["SI_PM_TAKE_ALL_BY_SUBJECT"]                = "Nach Betreff nehmen",
    ["SI_PM_TAKE_ALL_BY_SUBJECT_HELP_01"]        = "Mit der Taste |cFF00FFNach Betreff nehmen|r werden die Anhänge aller Nachrichten mit dem gleichen Betreff wie die ausgewählte Nachricht entfernt und die Nachrichten anschließend auf Wunsch gelöscht.",
    ["SI_PM_TAKE_ALL_BY_SENDER"]                 = "Nach Absender nehmen",
    ["SI_PM_TAKE_ALL_BY_SENDER_HELP_01"]         = "Mit der Taste |cFF00FFNach Absender nehmen|r werden die Anhänge aller Nachrichten mit dem gleichen Absenderkontonamen wie die ausgewählte Nachricht entfernt und die Nachrichten anschließend auf Wunsch gelöscht.",
    ["SI_PM_TAKE_ALL_BY_FIELD_HELP_02"]          = { "Verfügbar als optionales <<1>> auf der Tastatur (siehe Abschnitt <<2>> oben) und im Menü <<3>> auf dem Gamepad.", 
                                                     SI_BINDING_NAME_UI_SHORTCUT_QUATERNARY, SI_KEYBINDINGS_BINDINGS, SI_GAMEPAD_MAIL_INBOX_OPTIONS },

    --Baertram - Mail Send save message settings
    ["SI_PM_SENDMAIL_MESSAGE_RECIPIENTS"]        = "Empfänger speichern",   -- Save recipient
    ["SI_PM_SENDMAIL_MESSAGE_RECIPIENTS_TT"]     = "Sichere die Empfänger deiner manuell erstellten Mails. Du kannst die Liste der Gesicherten mit einem Rechtsklick auf das Empfänger Eingabefeld öffnen.",
    ["SI_PM_SENDMAIL_CLEAR_RECIPIENTS"]          = "Gespeicherte Empfänger löschen",
    ["SI_PM_SENDMAIL_CLEAR_RECIPIENTS_SUCCESS"]  = "Gespeicherte Empfänger erfolgreich gelöscht.",
    ["SI_PM_SENDMAIL_MESSAGE_SUBJECTS"]          = "Betreff speichern",     -- Save subject
    ["SI_PM_SENDMAIL_MESSAGE_SUBJECTS_TT"]       = "Sichere die Betreffs deiner manuell erstellten Mails. Du kannst die Liste der Gesicherten mit einem Rechtsklick auf das Betreff Eingabefeld öffnen.",
    ["SI_PM_SENDMAIL_CLEAR_SUBJECTS"]            = "Gespeicherte Betreffs löschen",
    ["SI_PM_SENDMAIL_CLEAR_SUBJECTS_SUCCESS"]    = "Gespeicherte Betreffs erfolgreich gelöscht.",
    ["SI_PM_SENDMAIL_MESSAGE_TEXT"]              = "Nachrichten-Text speichern", -- Save message body
    ["SI_PM_SENDMAIL_MESSAGE_TEXT_TT"]           = "Sichere den Mail Text deiner manuell erstellten Mails. Du kannst die Liste der Gesicherten mit einem Rechtsklick auf das Mail Text Eingabefeld öffnen.",
    ["SI_PM_SENDMAIL_CLEAR_MESSAGES"]            = "Gespeicherte Nachrichten-Text löschen",
    ["SI_PM_SENDMAIL_CLEAR_MESSAGES_SUCCESS"]    = "Gespeicherte Nachrichten-Texte erfolgreich gelöscht.",
    ["SI_PM_SENDMAIL_MESSAGE_RECENT_SUBJECTS"]   = "Zuletzt verwendete Betreffs",
    ["SI_PM_SENDMAIL_MESSAGE_RECENT_TEXT"]       = "Zuletzt verwendete Nachrichten",
    ["SI_PM_SENDMAIL_AMOUNT"]                    = "Anzahl gespeicherter Einträge",
    ["SI_PM_SENDMAIL_PREVIEW_CHARS"]             = "Anzahl Zeichen in Kontext Menü (Vorschau)",
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    POSTMASTER_STRINGS[stringId] = value
end