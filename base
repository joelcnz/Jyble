//#go through the whole Bible
//#the 2 is the |_ pieces
//#not sure about the seg bit
//#makes SongOfSolomon
//#old stuff

version = ESV; // ESV enabled
//version = EndOfBlock;

import std.stdio;
import std.string;
import std.file;
import std.conv;
import std.typecons; // may remove
import std.regex: regex, match;
import std.ascii;
import std.algorithm;
import std.range;
import std.typecons;

import jeca.misc;

version(ESV)
	import arsd.dom;
import bible, book, chapter, verse;

version(ESV)
	Document g_document;
Bible g_bible;

dchar[] g_word;

//#ELS - equal distance letter sequences
dchar[] scan(dchar[] text) {

	'-'.repeat.take(80).writeln;

	void elsPro(int letterHits, dchar[] word) {
		//mixin(traceLine("letterHits word".split));

		//alias jtoLower = std.uni.toLower;
		//word = word.map!(a => a.jtoLower).to!dstring.dup;
		dchar[] word2 = word.dup;
		foreach(char a; word)
			word2 ~= std.ascii.toLower(a);
		word = word2.to!dstring.dup;

		//writeln(text);

		int beginning;

		void findnth() {
			int start;
			for(; start < text.length && letterHits; start++) // find the nth count of the first letter of word
				if (text[start] == word[0])
					letterHits--;

			beginning = start - 1;
			//writeln(text);
		}

		if (beginning < 0)
			return;

		/+
          11111111112222222222333333333344444444445555555555666666
012345678901234567890123456789012345678901234567890123456789012345
inthebeginninggodcreatedtheheavenandtheearthandtheearthwaswithout
(g)inningg(o)dcreate(d)theheav
+/	
		findnth();

		//mixin(traceLine("text.length beginning text[beginning]".split));

		//writeln();
		// loop ends when either: success or 
		int pos = beginning, spaces;
		//const len = 1_000; //text.len;
		const len = text.length;
		//write(pos, ' ');

		spaces = 0;
		while(spaces < len / word.length && pos+1 < len &&
			  text[++pos] != word[1]) { // find second letter and the interval
			//mixin(trace("pos"));
			++spaces;
		}
		spaces++;

	if (! spaces < 3) {
			
			//mixin(traceLine("text[beginning..beginning+spaces*word.length]"));

		//mixin(traceLine("pos text[pos] spaces".split));

		bool success = true;
		for(int p, stride = beginning; p < word.length /+ , stride + spaces < text.length +/ ; p++, stride += spaces) {
				//mixin(traceLine("beginning"));
		//mixin(traceLine("beginning", "p", "spaces", "stride", "text[stride]", "word[p]"));
				if (text[stride] != word[p]) {
					success = false;

					break;
				}
			}

		if (success) {
			int targ;
			auto str = ' '.repeat.take(spaces-1).to!(dchar[]);
			for(int n = beginning; n < beginning + word.length * spaces; ++n) {
				if (targ == spaces || n == beginning) {
					targ = 0;
					//write('(', text[n], ')');
					writeln(
						(n-spaces+1 >= 0 ? text[n-spaces+1..n] : str),
						'(', text[n], ')',
						text[n+1..n+spaces]);
				}
				//else
				//	write(text[n]);
				targ++;
			}

			writeln();
		}
	} // if spaces < 3

	} // ELS

	//elsPro(1, "God"d.dup);
	
	// loop through Bible verses
	
	
	//elsPro(args[0].to!int, args[1].to!(dchar[]));
	version(EndOfBlock)
		text = text[text.length - 1100..$];
	version(all)
		text = "הִתְנַעֲרִי מֵעָפָר קוּמִי שְּׁבִי, יְרוּשָׁלִָם; התפתחו מוֹסְרֵי צַוָּארֵךְ, שְׁבִיָּה בַּת-צִיּוֹןכִּי-כֹה אָמַר יְהוָה, חִנָּם נִמְכַּרְתֶּם; וְלֹא בְכֶסֶף, תִּגָּאֵלוּכִּי כֹה אָמַר אֲדֹנָי יְהוִה, מִצְרַיִם יָרַד-עַמִּי בָרִאשֹׁנָה לָגוּר שָׁם; וְאַשּׁוּר, בְּאֶפֶס עֲשָׁקוֹ".to!(dchar[]);
	text = removechars(text.to!(dchar[]), " "d.dup);
	writeln(text);

	//int max = 1000; //cast(int)text.length / 3;
	int max = cast(int)text.length / 3;
	iota(1,max)
		.map!((n) { elsPro(n, g_word); /+ write("\r", n, " of ", max, ' '); +/ return n; } )
	.array;

	writeln();

	return text;
} // scan

string fixMultiBooks(string raw) {
	for(int i; i<raw.length; i++) {
		if (raw[i]=='|' && i+3<raw.length && raw[i+1]=='_' && raw[i+2].isDigit() && raw[i+3]==' ') {
			raw=raw[0..i+3]~raw[i+4..$]; 
		}
	}

	return raw;
}

struct Segment {
	size_t st, ed;
	
	void print(string raw) {
		writeln(seg(raw));
	}
	
	string seg(string raw) {

		return raw[st .. ed];
	}
}

size_t segs(size_t st, string data) {
	string result;
	string seg;
	bool dash = false;
	size_t ed = st + 1;
	for(;;) {
		char dat = data[ed];

		// if char not in pattern then terminate
		if (! dat.inPattern(std.ascii.digits ~ " -"))
			break;
		ed++;
		if (ed == data.length)
			break;
	}
	char dat;

	do 
		--ed;
	while(! data[ed].isDigit());
	ed++;

	return ed - st;
}

string convertReferencesFromNotesFile(string raw) {
	// collect tags and book titles
	auto r = regex(`[|][_]\w+`, "g");
	Segment[] seg;
	string[] verses;
	int i = 0;
	foreach(c; match(raw, r)) {
//		if (! any!((a) => a.isAlpha())(c.hit))
//			continue;
		size_t ed = c.pre.length + c.hit.length;
		ed += segs(ed, raw);
		seg ~= Segment(c.pre.length + 2, ed); //#the 2 is the '|_' pieces
		//seg[$-1].print(raw);
		auto parts = seg[$-1].seg(raw).split();
		//writeln(">",parts.join(" "),"<");

		if (parts.length > 1) {
			auto reveal = g_bible.argReference(parts);
			verses ~= reveal;
		}
		else
			seg.length--;
	}
	
	string goTogether() {
		string result;

		result = raw[0 .. seg[0].st - 2];
		debug(5)
			writeln("start>", result, "<");
		foreach(i, s; seg) {
			debug(5)
				writeln("verses>", verses[i], "<");
			string verse = verses[i]; //"|_" ~ verses[i];
			if (i + 1 < seg.length) {
				result ~= verse ~ raw[s.ed .. seg[i + 1].st - 2];
				debug(5)
					writeln("inter>", verse ~ raw[s.ed .. seg[i + 1].st - 2], "<");
			}
			else {
				result ~= verse ~ raw[s.ed .. $];
				debug(5)
					writeln("end>", verse ~ raw[s.ed .. $], "<");
			}
		}
		
		return result;
	}
	

//	writeln(result);

//	foreach(verse; verses)
//		writeln('#', verse, '#');

	//return result;
	return goTogether();
}

version(ESV) {
void loadXMLFile() {
	writeln( "Loading xml file.." );
    g_document = new Document(readText("esv.xml"));
}

void parseXMLDocument() {
	writeln( "Processing xml file.." );

    // the document is now the bible
    g_bible = new Bible;

    auto books = g_document.getElementsByTagName("b");
    foreach(i, book; books) {
       //auto nameOfBook = book.n; // "Genesis" for example. All xml attributes are available this same way

		//book.n = book.n.replace(" ", ""); //#makes SongOfSolomon
		alias book b;
		if (b.n[1] == ' ')
			b.n = b.n[0] ~ b.n[2 .. $];
		g_bible.m_books ~= new Book(b.n);

       auto chapters = book.getElementsByTagName("c");
       foreach(chapter; chapters) {
            auto verses = chapter.getElementsByTagName("v");
            
         	g_bible.m_books[$ - 1].m_chapters ~= new Chapter( chapter.n );

            foreach(verse; verses) {
                 auto v = verse.innerText;

				g_bible.m_books[$ - 1].m_chapters[$ - 1].m_verses ~= new Verse( verse.n );
				g_bible.m_books[$ - 1].m_chapters[$ - 1].m_verses[$ - 1].verse = v;
//                 // let's write out a passage
                //writeln(g_bible.m_books[$ - 1].m_bookTitle, " ", chapter.n, ":", verse.n, " ", v); // prints "Genesis 1:1 In the beginning, God created [...]
            }
       }
    }
    
}
} // version ESV

void convertReferencesFromFile() {
	File file = File("glean.txt", "w"); //#clear the text file
	file.close();
    foreach(reference; File("source.txt", "r").byLine)
		g_bible.argReference(reference.idup.split);    
}

void convertReferencesFromUserInput() {
	writeln("Enter Bible reference ('q' to quit):");
	string[] input;
	bool done = false;
    while(! done) {
		g_bible.argReference(input = readln().split()); //"Gen 1 1 - 2".split);
		if (input.length > 0 && input[0] == "q")
			done = true;
	}
}

//#old stuff
    //bible.print;
    //bible.argReference(args[1 .. $]); //"Gen 1 1 2".split);
void genListOfBookTitlesAndNums() {
	foreach(i, book; g_bible.m_books) {
		writefln("%2s - %s", i + 1, book.m_bookTitle);
	}
}

// I don't think this is even needed!
void generateEnumOfBooks() {
	string result = "enum BookId {\n";
	foreach(i, book; g_bible.m_books) {
		result ~= "\tb" ~ book.m_bookTitle ~ " = " ~ to!string(i + 1) ~ ",\n";
	}
	result = result[0 .. $ - 2] ~ "};";
	writeln(result);
}

dchar[] stripAndpack(ref string text) {
	char[] word = text.dup;
	char[] word2;
	foreach(char a; word)
		word2 ~= std.ascii.toLower(a);
	text = word2.to!string;

	//text = text.map!(a => a.toLower).to!string;
	
	text = text
	.filter!(a => a.inPattern(std.ascii.letters))
	.to!string;

	return text.to!(dchar[]);
}


//#go through the whole Bible
//void printWholeBible(alias fun)() {
void printWholeBible() {
	writeln("printWholeBible\n");

	dchar[] block;

	version(none) {
	foreach(i, book; g_bible.m_books) {
//		writeln("book ", i);
		write("\r", 66-i, ' '); stdout.flush;
		foreach(i2, chapter; book.m_chapters) {
//			writeln("chapter ", i2);
			foreach(i3, ref verse; chapter.m_verses) {
				block ~= stripAndpack(verse.verse);

//				writeln("verse ", i3);

				//writeln(stripAndpack(verse.verse));
				//scan( stripAndpack(verse.verse) );
			}
		}
		//goto label1;
	}
	write("\r  \r");
//label1:
	} // version

	block = readText("block.txt").to!(dchar[]);

	scan( block );
}

// the prefix 'b' is for book, variable names can't start with a digit.
enum BookId {
	bGenesis = 1,
	bExodus = 2,
	bLeviticus = 3,
	bNumbers = 4,
	bDeuteronomy = 5,
	bJoshua = 6,
	bJudges = 7,
	bRuth = 8,
	b1Samuel = 9,
	b2Samuel = 10,
	b1Kings = 11,
	b2Kings = 12,
	b1Chronicles = 13,
	b2Chronicles = 14,
	bEzra = 15,
	bNehemiah = 16,
	bEsther = 17,
	bJob = 18,
	bPsalms = 19,
	bProverbs = 20,
	bEcclesiastes = 21,
	bSongofSolomon = 22,
	bIsaiah = 23,
	bJeremiah = 24,
	bLamentations = 25,
	bEzekiel = 26,
	bDaniel = 27,
	bHosea = 28,
	bJoel = 29,
	bAmos = 30,
	bObadiah = 31,
	bJonah = 32,
	bMicah = 33,
	bNahum = 34,
	bHabakkuk = 35,
	bZephaniah = 36,
	bHaggai = 37,
	bZechariah = 38,
	bMalachi = 39,
	bMatthew = 40,
	bMark = 41,
	bLuke = 42,
	bJohn = 43,
	bActs = 44,
	bRomans = 45,
	b1Corinthians = 46,
	b2Corinthians = 47,
	bGalatians = 48,
	bEphesians = 49,
	bPhilippians = 50,
	bColossians = 51,
	b1Thessalonians = 52,
	b2Thessalonians = 53,
	b1Timothy = 54,
	b2Timothy = 55,
	bTitus = 56,
	bPhilemon = 57,
	bHebrews = 58,
	bJames = 59,
	b1Peter = 60,
	b2Peter = 61,
	b1John = 62,
	b2John = 63,
	b3John = 64,
	bJude = 65,
	bRevelation = 66};
