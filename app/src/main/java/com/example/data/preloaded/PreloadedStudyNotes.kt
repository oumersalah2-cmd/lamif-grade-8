package com.example.data.preloaded

data class StudyTopic(
  val id: String,
  val subjectId: String,
  val titleOm: String,
  val subtitleOm: String,
  val keyPointsOm: List<String>,
  val formulaOrRule: String = ""
)

object PreloadedStudyNotes {
  val notes: List<StudyTopic> = listOf(
    StudyTopic(
      id = "note_math_pythagoras",
      subjectId = "herrega",
      titleOm = "Tiwooremii Paayitaagorasii",
      subtitleOm = "Rog-sadee Sirrii (Right-angled Triangle)",
      keyPointsOm = listOf(
        "Rog-sadee kofa sirrii (90°) qabu qofaaf hojjeta.",
        "Rogi dheeraan kofa sirriitti fuulleffatu Haayipootinasii (c) jedhama.",
        "c² = a² + b² (Dheerina Haayipootinasii shallaguuf)",
        "a² = c² - b² fi b² = c² - a²"
      ),
      formulaOrRule = "c = √(a² + b²)"
    ),
    StudyTopic(
      id = "note_math_area",
      subjectId = "herrega",
      titleOm = "Bal'ina fi Marsee Rog-baay'eewwanii",
      subtitleOm = "Fakkoowwan Ji'oomeetirii Baramaa",
      keyPointsOm = listOf(
        "Bal'ina Rog-sadee: A = 1/2 × Bu'uura (b) × Dheerina (h)",
        "Bal'ina Rog-afree: A = Roga × Roga (s²)",
        "Bal'ina Geengoo: A = πr² (π ≈ 3.14 ykn 22/7)",
        "Marsee Geengoo (Circumference): C = 2πr"
      ),
      formulaOrRule = "A_triangle = 1/2 × b × h | A_circle = πr²"
    ),
    StudyTopic(
      id = "note_sci_cell",
      subjectId = "saayinsii_waliigalaa",
      titleOm = "Caasaa fi Qaamolee Lubbiyyoo (Cell)",
      subtitleOm = "Lubbiyyoo Biqiltootaa fi Bineensotaa",
      keyPointsOm = listOf(
        "Niwukilasii: Hojii lubbiyyoo hunda to'ata; ragaa dhaalmayaa (DNA) of keessaa qaba.",
        "Maaytookondiriyaa: Annisaa (ATP) uumuun mooraa annisaa seeliiti.",
        "Kilooropilaastii: Biqiltoota qofa keessatti argama; adeemsa footoosinteesisiif barbaachisa.",
        "Goba Lubbiyyoo (Cell wall): Seelii biqiltootaaf jabinna fi roga kenna."
      ),
      formulaOrRule = "Footoosinteesisii: 6CO₂ + 6H₂O + Iftuu -> C₆H₁₂O₆ + 6O₂"
    ),
    StudyTopic(
      id = "note_sci_motion",
      subjectId = "saayinsii_waliigalaa",
      titleOm = "Seerota Sochii Niwutan (Newton's Laws)",
      subtitleOm = "Humna, Ulfaatina fi Saffisa",
      keyPointsOm = listOf(
        "Seera 1ffaa: Wanti tokko yoo humni alaa irratti hin hojjenne sochii ykn tasgabbii isaa itti fufa (Inertia).",
        "Seera 2ffaa: Humni walqixa ulfaatina baay'isuu saffisiisaadha (F = m × a).",
        "Seera 3ffaa: Hojii hundaaf tarkaanfiin faallaa fi walqixa ta'e ni jira (Action = Reaction)."
      ),
      formulaOrRule = "F = m × a | W = F × d"
    ),
    StudyTopic(
      id = "note_ao_grammar",
      subjectId = "afaan_oromoo",
      titleOm = "Dhamjecha fi Caasaa Jechaa",
      subtitleOm = "Caasluga Afaan Oromoo Kutaa 8ffaa",
      keyPointsOm = listOf(
        "Dhamjecha Walaba: Of danda'ee hiika qaba (fkn: 'mana', 'nama', 'barreessi').",
        "Dhamjecha Hirkataa: Of danda'ee hiika hin kennu; dhamjecha walabatti maxxana.",
        "Dhamjechi hirkataan kutaalee lama qaba: Dhamjecha Horteefi Dhamjecha Uumaa.",
        "Dhamjechi horteen lakkoofsa, koorniyaa ykn qooda agarsiisa."
      ),
      formulaOrRule = "Jecha = Jirma + Dhamjecha Hirkataa"
    ),
    StudyTopic(
      id = "note_civ_rights",
      subjectId = "lammummaa",
      titleOm = "Mirga fi Dirqama Heeraa",
      subtitleOm = "Bu'uura Lammummaa Gaarii",
      keyPointsOm = listOf(
        "Mirgi namoomaa dhalootaan kan argamu fi hin sarbamneedha (Mirga jiraachuu, bilisummaa).",
        "Mirgi dimokraasii filachuu, filatamuu fi yaada ofii bilisaan ibsachuu dabalata.",
        "Dirqamni lammii: Seera kabajuu, gibira kaffaluu, nageenya eeguu fi qabeenya uumamaa kunuunsuudha."
      ),
      formulaOrRule = "Mirga + Dirqama = Dimokraasii Dhaabbataa"
    )
  )
}
