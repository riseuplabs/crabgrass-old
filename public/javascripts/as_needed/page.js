
// called from within the share_popup (add new recipient)
function new_recipient()  {
    // serialize Form
 
    // build Ajax Request
    var params = $('recipient_name').serialize() + "&" + $('recipient[access]').serialize();
    new Ajax.Request('/base_page/participation/new_recipient', {asynchronous:true, evalScripts:true, parameters:params, method: 'post'});
}


// global variables

var group_nav_items = [];
var group_user_items = [];

var check_all_checkbox = false;
var active_possible_contributors_group_menu_item = false;
var active_possible_contributors_group_user_selection = false;

function recipient_checked(checkbox, recipient_name) {
    if (checkbox.checked) {
	$(recipient_name + '_selected').show()
	    } else {
	$(recipient_name + '_selected').hide()
	    }
    $$('.recipient_checkbox_' + recipient_name).each( function(cb) {
	    cb.checked = checkbox.checked
		});
}

function loadHTMLElements(context) {

    switch(context) {
    case 'notify':
	
	group_nav_items = $('possible_contributors_group_selection').childElements();
	group_user_items = $('possible_contributors_from_group_container').childElements();
	check_all_checkbox = $('check_all_users');
	break;
    default:
    }

}


function notify_initialize() {
    // initializer for possible_contributors_group_selection

    loadHTMLElements('notify');
    
    notify_initialize_group_nav_items();
    notify_initialize_group_user_items();
    notify_initialize_check_all_checkbox();
 
}

function notify_initialize_group_nav_items() {
    group_nav_items.each(function(e) {
	    var group_element_name = Element.readAttribute(e,'id');
	    var group_name = group_element_name.sub('possible_contributors_group-','');
	    Event.observe(group_element_name,'click',function(e) {
		    if(active_possible_contributors_group_menu_item) {
			active_possible_contributors_group_menu_item.removeClassName('active_menu_item');
		    }
		    active_possible_contributors_group_menu_item = $(group_element_name);
		    $(group_element_name).addClassName('active_menu_item');		  
		    set_selected_group(group_name);
		});
	});
}

function notify_initialize_group_user_items() {
    // initialize for checking one user in all groups if checked once
    group_user_items.each(function(e) { 
	    e.hide();
	    var group_element_name = Element.readAttribute(e,'id');
	    var group_name = group_element_name.sub('possible_contributors_from_group-','');	
	    group_name = group_name.sub(/\+/,'\\+');	  
	    e.childElements().each(function(el) {
		    var user_element_name = Element.readAttribute(el,'id');
		    var user_name = user_element_name.sub('possible_contributor_from_group-'+group_name+'-user-','');
		    var user_checkbox = find_checkbox_in(el);
		    var user_checkbox_id = Element.identify(user_checkbox);
		    Event.observe(user_checkbox_id,'change',function(){
			    check_user_everywhere(user_name,user_checkbox.checked);
			    update_selected_user_count();
			});
		});
	});
    group_user_items.first().show();
    group_nav_items.first().addClassName('active_menu_item');
    active_possible_contributors_group_menu_item = group_nav_items.first();
    active_possible_contributors_group_user_selection = group_user_items.first();
}

function notify_initialize_check_all_checkbox() {
    // intialize for checking all users if check_all selected
    var element_name = Element.identify(check_all_checkbox);
    Event.observe(element_name,'change',function() {
	    check_all_users();
	});
} 


function check_all_users(){ 
    group_user_items.first().childElements().each(function(e) {
	    var checkbox = find_checkbox_in(e);
	    checkbox.checked = check_all_checkbox.checked;
	    var user_element_name = Element.identify(e);
	    var user_name = user_element_name.sub(/possible_contributor_from_group-.+-user-/,'');
	    check_user_everywhere(user_name,checkbox.checked)
	});
    update_selected_user_count();
}

// when a user is checkd in one group, we want to check it for all groups
function check_user_everywhere(user_name,checked) {
    $$('.possible_contributor-'+user_name).each(function(e) {
	    var checkbox = find_checkbox_in(e);
	    checkbox.checked = checked;
	});
}


// called from the notify_popup (when clicked on a group in the share with possible oontributors dialoque)
function set_selected_group(group_id) {
    group_user_items.each(function(e) { 
	    e.hide();
	});
    $('possible_contributors_from_group-'+group_id).show();
}

// internal helper methods

function find_checkbox_in(element) {
    var checkbox = element.childElements().find(function(s) {
	    return (s.readAttribute('type') == 'checkbox');
	});
    return checkbox;
}


function count_selected_users(group_id) {
    var count = 0;
    $('possible_contributors_from_group-'+group_id).childElements().each(function(e) {
	    var checkbox = find_checkbox_in(e);
	    if (checkbox.checked) {
		count++;
	    }

	});
    return count;
}

function update_selected_user_count(){
    group_nav_items.each(function(e){
	    var group_menu_item = e;
	    var group_name = Element.identify(group_menu_item).sub('possible_contributors_group-','');
	    var new_span = document.createElement("span");
	    var new_text = document.createTextNode("("+count_selected_users(group_name)+")");
	    new_span.appendChild(new_text);
	    
	    var group_menu_item_counter = Element.select(group_menu_item,'span');
	    group_menu_item_counter = group_menu_item_counter.first();
	    if (group_menu_item_counter) {
		group_menu_item.removeChild(group_menu_item_counter);
	    }
	    group_menu_item.appendChild(new_span);
	});
}