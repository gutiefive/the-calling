class_name ChapterSummary
extends RefCounted
## Short end-of-chapter recap. Facts about what the player did, not a score.


static func text() -> String:
	var lines: PackedStringArray = PackedStringArray()
	var keys := str(NarrativeState.get_flag("keys_approach", ""))
	if keys == "harold":
		lines.append("You asked Harold about the spare keys.")
	elif keys == "search":
		lines.append("You looked for the spare keys yourself.")
	else:
		lines.append("The spare keys stayed a loose end.")
	if NarrativeState.flag_is_true("frank_listened"):
		lines.append("You let Frank talk before you talked about Sunday.")
	elif NarrativeState.flag_is_true("frank_invited"):
		lines.append("You asked Frank to come on Sunday.")
	else:
		lines.append("Frank's bay stayed a brake job.")
	if NarrativeState.flag_is_true("sarah_heard"):
		lines.append("You asked Sarah what the week actually needs.")
	else:
		lines.append("You told Sarah that Sunday is at ten.")
	var theme := str(NarrativeState.get_flag("sermon_theme", ""))
	if theme == "hope":
		lines.append("The sermon was about hope.")
	elif theme == "forgiveness":
		lines.append("The sermon was about forgiveness.")
	elif theme == "service":
		lines.append("The sermon was about service.")
	else:
		lines.append("The sermon did not settle on a theme.")
	lines.append("Margaret opened the ledger. The plate will not cover the oil bill.")
	return "\n".join(lines)
