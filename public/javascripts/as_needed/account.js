var pw_sets = new Hash;
pw_sets.set(/[a-z]/, 26);
pw_sets.set(/[A-Z]/, 26);
pw_sets.set(/[0-9]/, 10);
pw_sets.set(/[^\w]/, 32);
function pw_strength(pw) {
    var set_size = 0;
    pw_sets.each(function (e) {
	    if(pw.match(eval(e[0]))) {
		set_size += e[1];
	    }
        });
    return Math.pow(set_size,pw.length)/1000.000/86400.0000/365.000;
}

function pw_days_to_crack(years)
{
    if(years > 100)
	return (years/100).toFixed(2)+" centuries";
    if(years > 1)
	return years.toFixed(2)+" years";
    days = years*365;
    if(days > 30)
	return (days/30).toFixed(0)+" months";
    if(days > 7)
	return (days/7).toFixed(0)+" weeks";
    if(days < 1 && days*24 > 1)
	return (days*24).toFixed(1)+" hours";
    if(days < 1 && days*24*60 > 1)
	return (days*24*60).toFixed(2)+" minutes";
    if(days < 1)
	return (days*24*60*60).toFixed(2)+" seconds";
    return days.toFixed(1)+" days";
}

function pw_bar_class(pw, min_strength) {
    if(pw.length == 0) {
	$('pw_crack_time').innerHTML = "??";
	return 0;
    }
    if(pw == $('user_login').value) {
	$('pw_crack_time').innerHTML = "a human being";
	return 0;
    }
    var s = pw_strength(pw);
    $('pw_crack_time').innerHTML = pw_days_to_crack(s);
    if(s > min_strength*1.5)
	return "pw_bar_100";
    if(s >= min_strength)
	return "pw_bar_75";
    if(s > min_strength/3)
	return "pw_bar_50";
    if(s < (min_strength/3))
	return "pw_bar_25";

}
function set_pw_bar(password, min_strength) {
    $('pw_bar').removeClassName('pw_bar_25');
    $('pw_bar').removeClassName('pw_bar_50');
    $('pw_bar').removeClassName('pw_bar_75');
    $('pw_bar').removeClassName('pw_bar_100');
    $('pw_bar').addClassName(pw_bar_class(password, min_strength));
}
