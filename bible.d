//#new
//#chapter not limited, and crash!
//#but args are strings already!
//#but what about "1Joh 2 3 - -1", the "-"'s get removed
//#not work
//#eg 'Gen 1 1 -' -- get whole chapter
//#clear the text file

//version = DUnit; // dep
version = OldVersion;
version = ModifyTitle; // '1John' to '1 John'

import std.stdio;
import std.string;
import std.array: split, replace;
import std.file;
import std.conv;
import std.ascii;

//import dunit;
import jeca.misc;
import base, book;

class Bible {
	Book[] m_books;

	size_t parseNumber(in size_t max, in size_t number) pure {
		if (number < 0) {
			//debug
			//	writeln("parse: ", max + number % max);
			return max + number % max;
		} else if (number > max-1){
			return max-1; // or return parseNumber(max, number-max);
		}

		if (number == 0)
			return 1;

		return number;
	}
	
	/// returns 1 if input invalid
	size_t toInt(in string str) {
		scope(failure)
			return 1;
		return str.to!size_t();
	}

	// "1 Joh 2:3-4" - "1Joh 2 3 - 4" //#but what about "1Joh 2 3 - -1", the "-"'s get removed
	string[] argReferenceToArgs(string str) {
		string bookTitle;
		bool alpha = false;
		foreach(i, c; str) {
			if (alpha == false && c.isAlpha()) {
				alpha = true;
			}

			if (alpha && (i+1 == str.length || c == ' ') ) {
				break;
			}

			if (c != ' ') {
				bookTitle ~= c;
			}

		}

		size_t[] inNum(string s) {
			size_t i = bookTitle.length;
			char[] cs = s[i..$].dup;
			//int count;

			foreach(ref c; cs) {
				if (! c.isDigit()) {
					c = ' ';
				}
			}

			auto str = cs.idup;
			auto result = str.split().to!(size_t[]);

			return result;
		}

		auto nums = inNum(str);

		string s;
		foreach(i, n; nums) {
			if (i == 2 && nums.length>2) {
				s ~= " - ";
			}
			s ~= n.to!string() ~ " ";
		}

		auto result = (bookTitle~" "~s).split();

		mixin(trace("result"));

		return result;
	}
	
	int bookNumberFromTitle(string bookTitle) {
		enum NA = -1; // Genesis
		size_t bookNumber = NA;
		
		bookTitle = replace(bookTitle, "|_", "");
		
		foreach(i, book; m_books)
			if (book.m_bookTitle.length >= bookTitle.length
				&& book.m_bookTitle[0 .. bookTitle.length].toLower == bookTitle.toLower) {
				bookNumber = i + 1;
				break;
			}
			
		if (bookNumber == NA) {
			writeln("No book match for '", bookTitle, "'");

			return NA;
		}
		
		return bookNumber;
	}

	/// Enter verse ref (eg. 'Psal 32 1 - -1')
	string argReference(string[] args) {
		if (args.length == 0) {
			writeln("I'm afraid that's quite out of the question!");
			return "";
		}

		// eg Psal 32 1 - -1
		if (args.length == 1) {
			writeln("not whole books yet");
			return "";
		}

		//args = "1 John 5 7".split();
		//writeln(args);
		if (args[0].length == 1) {
			string num = args[0].to!string(); //#but args are strings already!
			args[1]=num~args[1];
			args = args[1..$];
			//writeln(args);
		}

		enum NA = -1;
		size_t bookNumber;
		if (args[0].toLower() == "book") {
			bookNumber = parseNumber(66 + 1, toInt(args[1])); //#note the '+ 1', because it is what the user put
			args = args[1 .. $]; // pop the front
		}
		else {
			bookNumber = bookNumberFromTitle(args[0]); // eg args[0] might be 'Genesis'
			if (bookNumber == -1)
				return "";
		}
				
		size_t chapterNumber = parseNumber(
								m_books[bookNumber - 1].m_chapters.length + 1,
								toInt(args[1]));
		
		//writeln("bookNumber: ", bookNumber, " chapterNumber: ", chapterNumber);
		//#why m_verses.length + 1
		size_t verseNumber, verseNumber2;

		/* eg Gen 1 */
		if (args.length == 2) {
			args.length += 3;
			args[2]="1";
			args[$-2]="-";
			//#chapter not limited, and crash!
			args[$-1]=(m_books[bookNumber - 1].m_chapters[chapterNumber - 1].m_verses.length).to!string();
		}
	
		if (args.length > 2) {
			size_t vnum;
			try {
				vnum = parseNumber(m_books[bookNumber - 1].m_chapters[chapterNumber - 1].m_verses.length + 1
					, toInt(args[2]));
			if (bookNumber <= m_books.length
				&& chapterNumber <= m_books[bookNumber - 1].m_chapters.length
				//&& toInt(args[2]) <= m_books[bookNumber - 1].m_chapters[chapterNumber - 1].m_verses.length) {
			) {
				verseNumber = parseNumber(m_books[bookNumber - 1].m_chapters[chapterNumber - 1].m_verses.length + 1
					, toInt(args[2]));
			}
			else debug
				writeln("<zap>");
			} // try
			catch(Error er) {}
		}
		else
			//whole chapter
			verseNumber = 1,
			verseNumber2 = m_books[bookNumber - 1].m_chapters[chapterNumber - 1].m_verses.length + 1;

		//#eg 'Gen 1 1 -' -- get whole chapter
		//if (args.length == 4)
		//	args ~= (m_books[bookNumber - 1].m_chapters[chapterNumber - 1].m_verses.length + 1).to!string;
		if (args.length > 4)
			verseNumber2 =
				parseNumber(m_books[bookNumber - 1].m_chapters[chapterNumber - 1].m_verses.length + 1, toInt(args[4]));
		
		// '- 1' before this and not after this
		size_t dummyBook, dummyChapter;
		reduceNumbers(bookNumber, chapterNumber, verseNumber, dummyBook, dummyChapter, verseNumber2);
		
		string result;
		if (args.length < 5) {
			if (args.length == 2)
				result = getVerseRange(bookNumber, chapterNumber, verseNumber, bookNumber, chapterNumber, verseNumber2);
			else
				result = getVerseRange(bookNumber, chapterNumber, verseNumber, bookNumber, chapterNumber, verseNumber);
		}
		else
			result = getVerseRange(bookNumber, chapterNumber, verseNumber, bookNumber, chapterNumber, verseNumber2);
		
		if (1==2)
			writeln(result);

		return result;
	}
		
	void reduceNumbers(ref size_t book, ref size_t chapter, ref size_t verse, ref size_t book2, ref size_t chapter2, ref size_t verse2) {
		foreach(id; [&book, &chapter, &verse, &book2, &chapter2, &verse2])
			--(*id);
	}
	
	//#new
	string getReference(int bookNum, int chapterNum = 0, int verseNum = 0) {
		return "";
	}

	Book getBook(int bookNum) {
		//m_books[bookNumber - 1].m_chapters[chapterNumber - 1].m_verses.length + 1

		return m_books[bookNum - 1]; // I removed the '- 1'
	}

	string getVerseRange(size_t book, size_t chapter, size_t verse, size_t book2, size_t chapter2, size_t verse2) {
		scope(failure) {
			writefln("get verse range: An error has happen!"
				"\nBook: %s, chapter: %s, verse: %s, book2: %s, chapter2: %s, verse2: %s",
				book, chapter, verse, book2, chapter2, verse2);
			return "";
		}

		auto inBook = false,
			inChapter = false,
			inVerse = false;
		string verses = "";
		
		version(OldVersion)
		{} else {
			size_t cbook = book;
			size_t cchapter = chapter; 
			size_t cverse = verse; // c for current
			writeln("Start verse: book", book, " chapter: ", chapter, ", verse: ", verse);
			writeln("End verse: book", book2, " chapter: ", chapter2, ", verse: ", verse2);
			readln();
			do {
				writeln("Start: cbook", cbook, " cchapter: ", cchapter, ", cverse: ", cverse);
				readln();
				if (! inBook) {
					verses ~= m_books[cbook].m_bookTitle ~ ' ' ~ m_books[cbook].m_chapters[cchapter].m_chapterTitle ~ ":";
					inBook = true;
				}
				if (! inChapter) {
					inChapter = true;
				}
				if (! inVerse) {
					verses ~= m_books[cbook].m_chapters[cchapter].m_verses[cverse].m_verseTitle ~ (inVerse ? " " : " -- ") ~ m_books[cbook].m_chapters[cchapter].m_verses[cverse].m_verse ~ '\n';
					inVerse = true;
				}
				cverse++;
				//if (cbook == book2 && cchapter == chapter2 && cverse > verse2)
				if (cverse == m_books[cbook].m_chapters[cchapter].m_verses.length) {
					cverse = 0;
					cchapter++;
					if (cchapter == m_books[cbook].m_chapters.length) {
						cchapter = 0;
						cbook++;
						if (cbook == book2) {
							
						}
					}
					/+
					if (cchapter == chapter2) {
						cbook++;
						if (cbook == book2) {
							//this in handled with the while loop expression
						}
					}
					+/
					//inBook = false;
					//inChapter = false;
					inVerse = false;
				} // if (cverse
	//			writeln("Start: cbook", cbook, " cchapter: ", cchapter, ", cverse: ", cverse);
	//			readln();
			} while(!(cbook == book2 && cchapter == chapter2 && cverse == verse2 + 1));
		} // version
		
		/+
		//not work very far
		foreach(booko; m_books[book .. book + (book2 - book) + 1]) {
			bookChange = chapterChange = verseChange = false;
			verses ~= m_books[book].m_bookTitle ~ ' ' ~ m_books[book].m_chapters[chapter].m_chapterTitle ~ ":";
			foreach(chaptero; booko.m_chapters[chapter .. chapter + (chapter2 - chapter) + 1])
				foreach(verseo; chaptero.m_verses[verse .. verse + (verse2 - verse) + 1]) {
					verses ~= verseo.m_verseTitle ~ (verseChange ? " " : " -- ") ~ verseo.m_verse ~ '\n';
					verseChange = true;
				}
		}
		+/

		//just from within a chapter
		version(OldVersion) {
			inVerse = false;
			string bookTitle = m_books[book].m_bookTitle;
			version(ModifyTitle) {
				if (bookTitle[0].isDigit()) {
					bookTitle = bookTitle[0] ~ " " ~ bookTitle[1 .. $];
				}
			}
			verses ~= bookTitle ~ ' ' ~ m_books[book].m_chapters[chapter].m_chapterTitle ~ ":";
			foreach(verseo; m_books[book].m_chapters[chapter].m_verses[verse .. verse + (verse2 - verse) + 1]) {
				verses ~= verseo.m_verseTitle ~ (inVerse ? " " : " -- ") ~ verseo.m_verse ~ '\n';
				inVerse = true;
			}
		}

		append("glean.txt", verses);
		
		return verses;
	}
}

version(DUnit)
class BibleTests {
	mixin TestMixin;
	
	//alias g_bible this; // this; //#not work here with DUnit
	alias bible = g_bible;
	
	void testNotesReferenceExpand() {
		auto start ="I went |_John 11 35for a walk.";
		auto conversion = convertReferencesFromNotesFile(start);
		string test = "I went John 11:35 -@- Jesus wept.\nfor a walk.";

		debug(0) {
			writeln("     start>", [start], "<");
			writeln("conversion>", [conversion], "<");
			writeln("      test>", [test], "<");
		}

		assertEquals(conversion, test);
	}
	
	debug(10) {
		void testParseReferencies() {
			// Assert
			with(bible)
				assert(parseNumber( /+ number of chapters etc: +/ 10, /+ position +/ -1) == 9),
				assert(parseNumber(10, -11) == 9),
				assert(parseNumber(10, 0) == 0),
				assert(parseNumber(10, 1) == 1);
		}
		
		void testParseInput() {
			// Assert
			with(bible)
				assert(toInt("-1") == -1, "not -1"),
				assert(toInt("1") == 1, "not 1"),
				assert(toInt("a") == 1),
				assert(toInt("a.2f") == 1),
				assert(toInt("a.2-f") == 1),
				assert(toInt("") == 1);
		}
		
		void testReduceByOne() {
			int a,b,c,d,e,f;
			a = b = c = d = e = f = 1;
			bible.reduceNumbers(a,b,c,d,e,f);
			int result = a+b+c+d+e+f;
			assert(result == 0);
		}
		
		void testInputRef() {
			enum End {fromStart, fromEnd}
			with(bible) {
				string vref(string str, End end = End.fromStart) {
					string result = argReference(str.split());
					writeln("'", result, "'");

					//result = result[end == End.fromStart ? 0 : result.length - str.length
					//	.. end == End.fromStart ? str.length : result.length];

					if (end == End.fromStart)
						result = result[0 .. str.length];
					//writeln("result - '", result, "'");

					return result;
				}
				//assert(argReference("Genesis 1 1".split)[0 .. 11] == "Genesis 1:1");
				//assert(argReference("Genesis  1".split
				assert(vref("Genesis 1 1") == "Genesis 1:1");
				assert(vref("genesis 2 1") == "Genesis 2:1");
				assert(vref("Genesis -1 -1") == "Genesis 50:26");
				//assert(vref("Genesis -1") == "Genesis 50:1");
				assert(vref("Revelation -1 -1") == "Revelation 22:21");
				assert(vref("Psalms 119 -1 ") == "Psalms 119:176");
			}
		}
	} // debug 10
}
