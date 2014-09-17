class Verse {
	string m_verseTitle;
	string m_verse;
	this( string verseTitle ) {
		m_verseTitle = verseTitle;
	}
	
	@property ref string verse() pure { return m_verse; } // getter and setter
}
