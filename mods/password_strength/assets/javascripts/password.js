String.prototype.strReverse = function() {
  var newstring = "";
  for (var s=0; s < this.length; s++) {
    newstring = this.charAt(s) + newstring;
  }
  return newstring;
  //strOrig = ' texttotrim ';
  //strReversed = strOrig.revstring();
};
// http://www.whatsmypass.com/?p=415
var top_500_worst_passwords = ["123456", "porsche", "firebird", "prince", "rosebud", "password", "guitar", "butter", "beach", "jaguar", "12345678", "chelsea", "united", "amateur",
"great", "1234", "black", "turtle", "7777777", "cool", "pussy", "diamond", "steelers", "muffin", "cooper", "12345", "nascar", "tiffany", "redsox", "1313", "dragon", "jackson",
"zxcvbn", "star", "scorpio", "qwerty", "cameron", "tomcat", "testing", "mountain", "696969", "654321", "golf", "shannon", "madison", "mustang", "computer", "bond007", "murphy",
"987654", "letmein", "amanda", "bear", "frank", "brazil", "baseball", "wizard", "tiger", "hannah", "lauren", "master", "xxxxxxxx", "doctor", "dave", "japan", "michael", "money",
"gateway", "eagle1", "naked", "football", "phoenix", "gators", "11111", "squirt", "shadow", "mickey", "angel", "mother", "stars", "monkey", "bailey", "junior", "nathan", "apple",
"abc123", "knight", "thx1138", "raiders", "alexis", "pass", "iceman", "porno", "steve", "aaaa", "fuckme", "tigers", "badboy", "forever", "bonnie", "6969", "purple", "debbie",
"angela", "peaches", "jordan", "andrea", "spider", "viper", "jasmine", "harley", "horny", "melissa", "ou812", "kevin", "ranger", "dakota", "booger", "jake", "matt", "iwantu",
"aaaaaa", "1212", "lovers", "qwertyui", "jennifer", "player", "flyers", "suckit", "danielle", "hunter", "sunshine", "fish", "gregory", "beaver", "fuck", "morgan", "porn", "buddy", "4321", "2000",
"starwars", "matrix", "whatever", "4128", "test", "boomer", "teens", "young", "runner", "batman", "cowboys", "scooby", "nicholas", "swimming", "trustno1", "edward", "jason", "lucky", "dolphin",
"thomas", "charles", "walter", "helpme", "gordon", "tigger", "girls", "cumshot", "jackie", "casper", "robert", "booboo", "boston", "monica", "stupid", "access", "coffee", "braves", "midnight",
"shit", "love", "xxxxxx", "yankee", "college", "saturn", "buster", "bulldog", "lover", "baby", "gemini", "1234567", "ncc1701", "barney", "cunt", "apples", "soccer", "rabbit", "victor", "brian",
"august", "hockey", "peanut", "tucker", "mark", "3333", "killer", "john", "princess", "startrek", "canada", "george", "johnny", "mercedes", "sierra", "blazer", "sexy", "gandalf", "5150", "leather",
"cumming", "andrew", "spanky", "doggie", "232323", "hunting", "charlie", "winter", "zzzzzz", "4444", "kitty", "superman", "brandy", "gunner", "beavis", "rainbow", "asshole", "compaq", "horney", "bigcock",
"112233", "fuckyou", "carlos", "bubba", "happy", "arthur", "dallas", "tennis", "2112", "sophie", "cream", "jessica", "james", "fred", "ladies", "calvin", "panties", "mike", "johnson", "naughty", "shaved",
"pepper", "brandon", "xxxxx", "giants", "surfer", "1111", "fender", "tits", "booty", "samson", "austin", "anthony", "member", "blonde", "kelly", "william", "blowme", "boobs", "fucked", "paul", "daniel",
"ferrari", "donald", "golden", "mine", "golfer", "cookie", "bigdaddy", "0", "king", "summer", "chicken", "bronco", "fire", "racing", "heather", "maverick", "penis", "sandra", "5555", "hammer", "chicago",
"voyager", "pookie", "eagle", "yankees", "joseph", "rangers", "packers", "hentai", "joshua", "diablo", "birdie", "einstein", "newyork", "maggie", "sexsex", "trouble", "dolphins", "little", "biteme", "hardcore",
"white", "0", "redwings", "enter", "666666", "topgun", "chevy", "smith", "ashley", "willie", "bigtits", "winston", "sticky", "thunder", "welcome", "bitches", "warrior", "cocacola", "cowboy", "chris", "green", "sammy",
"animal", "silver", "panther", "super", "slut", "broncos", "richard", "yamaha", "qazwsx", "8675309", "private", "fucker", "justin", "magic", "zxcvbnm", "skippy", "orange", "banana", "lakers", "nipples", "marvin", "merlin",
"driver", "rachel", "power", "blondes", "michelle", "marine", "slayer", "victoria", "enjoy", "corvette", "angels", "scott", "asdfgh", "girl", "bigdog", "fishing", "2222", "vagina", "apollo", "cheese", "david", "asdf", "toyota",
"parker", "matthew", "maddog", "video", "travis", "qwert", "121212", "hooters", "london", "hotdog", "time", "patrick", "wilson", "7777", "paris", "sydney", "martin", "butthead", "marlboro", "rock", "women", "freedom", "dennis",
"srinivas", "xxxx", "voodoo", "ginger", "fucking", "internet", "extreme", "magnum", "blowjob", "captain", "action", "redskins", "juice", "nicole", "bigdick", "carter", "erotic", "abgrtyu", "sparky", "chester", "jasper", "dirty",
"777777", "yellow", "smokey", "monster", "ford", "dreams", "camaro", "xavier", "teresa", "freddy", "maxwell", "secret", "steven", "jeremy", "arsenal", "music", "dick", "viking", "11111111", "access14", "rush2112", "falcon", "snoopy",
"bill", "wolf", "russia", "taylor", "blue", "crystal", "nipple", "scorpion", "111111", "eagles", "peter", "iloveyou", "rebecca", "131313", "winner", "pussies", "alex", "tester", "123123", "samantha", "cock", "florida", "mistress", "bitch",
"house", "beer", "eric", "phantom", "hello", "miller", "rocket", "legend", "billy", "scooter", "flower", "theman", "movie", "6666", "please", "jack", "oliver", "success", "albert"];
/* proudly stolen from http://www.passwordmeter.com/pwd_meter.zip (GPL v2) */
function pw_bar_class_and_complexity(pwd, min_strength) {
  var nScore = 0;
  var nLength = 0;
  var nAlphaUC = 0;
  var nAlphaLC = 0;
  var nNumber = 0;
  var nSymbol = 0;
  var nMidChar = 0;
  var nRequirements = 0;
  var nAlphasOnly = 0;
  var nNumbersOnly = 0;
  var nRepChar = 0;
  var nConsecAlphaUC = 0;
  var nConsecAlphaLC = 0;
  var nConsecNumber = 0;
  var nConsecSymbol = 0;
  var nConsecCharType = 0;
  var nSeqAlpha = 0;
  var nSeqNumber = 0;
  var nSeqChar = 0;
  var nReqChar = 0;
  var nReqCharType = 3;
  var nMultLength = 4;
  var nMultAlphaUC = 3;
  var nMultAlphaLC = 3;
  var nMultNumber = 4;
  var nMultSymbol = 6;
  var nMultMidChar = 2;
  var nMultRequirements = 2;
  var nMultRepChar = 1;
  var nMultConsecAlphaUC = 2;
  var nMultConsecAlphaLC = 2;
  var nMultConsecNumber = 2;
  var nMultConsecSymbol = 1;
  var nMultConsecCharType = 0;
  var nMultSeqAlpha = 3;
  var nMultSeqNumber = 3;
  var nTmpAlphaUC = "";
  var nTmpAlphaLC = "";
  var nTmpNumber = "";
  var nTmpSymbol = "";
  var sAlphas = "abcdefghijklmnopqrstuvwxyz";
  var sNumerics = "01234567890";
  var sComplexity = "Too Short";
  var nMinPwdLen = 5 + min_strength;

  nScore = parseInt(pwd.length * nMultLength);
  nLength = pwd.length;
  var arrPwd = pwd.replace (/\s+/g,"").split(/\s*/);
  var arrPwdLen = arrPwd.length;

  /* Loop through password to check for Symbol, Numeric, Lowercase and Uppercase pattern matches */
  for (var a=0; a < arrPwdLen; a++) {
    if (arrPwd[a].match(new RegExp(/[A-Z]/g))) {
      if (nTmpAlphaUC !== "") { if ((nTmpAlphaUC + 1) == a) { nConsecAlphaUC++; nConsecCharType++; } }
      nTmpAlphaUC = a;
      nAlphaUC++;
    }
    else if (arrPwd[a].match(new RegExp(/[a-z]/g))) {
      if (nTmpAlphaLC !== "") { if ((nTmpAlphaLC + 1) == a) { nConsecAlphaLC++; nConsecCharType++; } }
      nTmpAlphaLC = a;
      nAlphaLC++;
    }
    else if (arrPwd[a].match(new RegExp(/[0-9]/g))) {
      if (a > 0 && a < (arrPwdLen - 1)) { nMidChar++; }
      if (nTmpNumber !== "") { if ((nTmpNumber + 1) == a) { nConsecNumber++; nConsecCharType++; } }
      nTmpNumber = a;
      nNumber++;
    }
    else if (arrPwd[a].match(new RegExp(/[^a-zA-Z0-9_]/g))) {
      if (a > 0 && a < (arrPwdLen - 1)) { nMidChar++; }
      if (nTmpSymbol !== "") { if ((nTmpSymbol + 1) == a) { nConsecSymbol++; nConsecCharType++; } }
      nTmpSymbol = a;
      nSymbol++;
    }
    /* Internal loop through password to check for repeated characters */
    for (var b=0; b < arrPwdLen; b++) {
      if (arrPwd[a].toLowerCase() == arrPwd[b].toLowerCase() && a != b) { nRepChar++; }
    }
  }

  /* Check for sequential alpha string patterns (forward and reverse) */
  for (var s=0; s < 23; s++) {
    var sFwd = sAlphas.substring(s,parseInt(s+3));
    var sRev = sFwd.strReverse();
    if (pwd.toLowerCase().indexOf(sFwd) != -1 || pwd.toLowerCase().indexOf(sRev) != -1) { nSeqAlpha++; nSeqChar++;}
  }

  /* Check for sequential numeric string patterns (forward and reverse) */
  for (var s=0; s < 8; s++) {
    var sFwd = sNumerics.substring(s,parseInt(s+3));
    var sRev = sFwd.strReverse();
    if (pwd.toLowerCase().indexOf(sFwd) != -1 || pwd.toLowerCase().indexOf(sRev) != -1) { nSeqNumber++; nSeqChar++;}
  }

  /* Modify overall score value based on usage vs requirements */

  /* General point assignment */
  if (nAlphaUC > 0 && nAlphaUC < nLength) {
    nScore = parseInt(nScore + ((nLength - nAlphaUC) * 2));
  }
  if (nAlphaLC > 0 && nAlphaLC < nLength) {
    nScore = parseInt(nScore + ((nLength - nAlphaLC) * 2));
  }
  if (nNumber > 0 && nNumber < nLength) {
    nScore = parseInt(nScore + (nNumber * nMultNumber));
  }
  if (nSymbol > 0) {
    nScore = parseInt(nScore + (nSymbol * nMultSymbol));
  }
  if (nMidChar > 0) {
    nScore = parseInt(nScore + (nMidChar * nMultMidChar));
  }

  /* Point deductions for poor practices */
  if ((nAlphaLC > 0 || nAlphaUC > 0) && nSymbol === 0 && nNumber === 0) {  // Only Letters
    nScore = parseInt(nScore - nLength);
    nAlphasOnly = nLength;
  }
  if (nAlphaLC === 0 && nAlphaUC === 0 && nSymbol === 0 && nNumber > 0) {  // Only Numbers
    nScore = parseInt(nScore - nLength);
    nNumbersOnly = nLength;
  }
  // if (nRepChar > 0) {  // Same character exists more than once
  //   nScore = parseInt(nScore - (nRepChar * nRepChar));
  // }
  if (nConsecAlphaUC > 0) {  // Consecutive Uppercase Letters exist
    nScore = parseInt(nScore - (nConsecAlphaUC * nMultConsecAlphaUC));
  }
  if (nConsecAlphaLC > 0) {  // Consecutive Lowercase Letters exist
    nScore = parseInt(nScore - (nConsecAlphaLC * nMultConsecAlphaLC));
  }
  if (nConsecNumber > 0) {  // Consecutive Numbers exist
    nScore = parseInt(nScore - (nConsecNumber * nMultConsecNumber));
  }
  if (nSeqAlpha > 0) {  // Sequential alpha strings exist (3 characters or more)
    nScore = parseInt(nScore - (nSeqAlpha * nMultSeqAlpha));
  }
  if (nSeqNumber > 0) {  // Sequential numeric strings exist (3 characters or more)
    nScore = parseInt(nScore - (nSeqNumber * nMultSeqNumber));
  }

  /* Determine complexity based on overall score */
  sPwBarClass = ""
  if (nScore > 100) { nScore = 100; } else if (nScore < 0) { nScore = 0; }
  if (nScore >= 0 && nScore < 20) { sComplexity = "Very Weak"; }
  else if (nScore >= 20 && nScore < 40) { sComplexity = "Weak"; sPwBarClass = "pw_bar_25"; }
  else if (nScore >= 40 && nScore < 60) { sComplexity = "Better";  sPwBarClass = "pw_bar_50"; }
  else if (nScore >= 60 && nScore < 80) { sComplexity = "Strong";  sPwBarClass = "pw_bar_75"; }
  else if (nScore >= 80 && nScore <= 100) { sComplexity = "Very Strong";  sPwBarClass = "pw_bar_100"; }

  var sLogin = $('user_login').value;
  if (pwd.include(sLogin))
  {
    sPwBarClass = "";
    sComplexity = "Very Weak (contains login name)";
  }
  top_500_worst_passwords.each(function(bad_pwd) {
     if (pwd.include(bad_pwd) && (pwd.length - bad_pwd.length < 3))
     {
       sPwBarClass = "";
       sComplexity = "Very Weak (too common)";
     }
   });

  return [sPwBarClass, sComplexity];
}

function set_pw_bar(password, min_strength) {
  $('pw_bar').removeClassName('pw_bar_25');
  $('pw_bar').removeClassName('pw_bar_50');
  $('pw_bar').removeClassName('pw_bar_75');
  $('pw_bar').removeClassName('pw_bar_100');

  var complexity_results = pw_bar_class_and_complexity(password, min_strength);
  var pw_bar_class = complexity_results[0];
  var pw_complexity_text = complexity_results[1];

  $('pw_time_to_crack').show();
  $('pw_time_to_crack').innerHTML = pw_complexity_text;
  $('pw_bar').addClassName(pw_bar_class);
}
