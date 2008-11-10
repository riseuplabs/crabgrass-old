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
    return (years/100).toFixed(0) + " " + $('date_centuries').value;
  if(years > 1)
    return years.toFixed(0) + " " + $('date_years').value;
  days = years*365;
  if(days > 30)
    return (days/30).toFixed(0) + " " + $('date_months').value;
  if(days > 7)
    return (days/7).toFixed(0) + " " + $('date_weeks').value;
  if(days < 1 && days*24 > 1)
    return (days*24).toFixed(0) + " " + $('date_hours').value;
  if(days < 1 && days*24*60 > 1)
    return (days*24*60).toFixed(0) + " " + $('date_minutes').value;
  if(days < 1)
    return (days*24*60*60).toFixed(0) + " " + $('date_seconds').value;
  return days.toFixed(0) + " " + $('date_days').value;
}

function pw_bar_class(pw, min_strength) {
  $('pw_time_to_crack').show();
  if(pw.length == 0) {
    $('pw_time').innerHTML = "0 " + $('date_seconds').value;
    return 0;
  }
  if(pw == $('user_login').value) {
    $('pw_time').innerHTML = "a human being";
    return 0;
  }
  var s = pw_strength(pw);
  $('pw_time').innerHTML = pw_days_to_crack(s);
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
