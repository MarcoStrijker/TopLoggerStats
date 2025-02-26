gymsFetched = {};

function textGymSearch() {
    // Filter gyms based on user input
    var searchTerm = $('.gym_search').val().toLowerCase().trim();
    var ascendType = $("#climb-type > .option > input[name='climb-type']:checked").val();
    $('.gyms .option').each(function(){
        if ($(this).attr('data-' + ascendType) == 'True' &&
            ($(this).attr('data-search-term').indexOf(searchTerm) > -1 || searchTerm.length < 1)) {
            $(this).show();
        } else {
            $(this).hide();
        }
    });
}

function R(){
    $('.gym_search').val('');
    textGymSearch();
}

function switchClimbType(event) {
    // On changing the climb-type, display the right grading-system, empty arr, uncheck every gym,
    // display gym with the corresponding climb types
    $("#grading-system-boulder, #grading-system-route").hide()
    $("#grading-system-" + event.target.value).show()
    $("#grading-system-" + event.target.value + " > div > input[value=french]").prop("checked", true);

    $('.gym_search').val('');

    // Check if gym has climbs with the selected climb type
    $('.gyms .option > input').each(function(){
        $(this).prop('checked', false)
        if ($(this).parent().attr('data-' + event.target.value) == 'True') {
            $(this).parent().show();
        } else {
            $(this).parent().hide();
        }
    });
}

function mainFormSubmit() {
    let username = $("#username > option:selected").text().trim();
    let uid = $("#username > option:selected").val()
    let gym = $("#username-gym option:selected").text()

    if (username === "Select a gym first" || username === "Select your username") {
        alert("You have to select whose stats you want to see")
        return false
    } else if (uid.length !== 10 || isNaN(uid)) {
        alert("Something went wrong determining who you are in TopLogger")
        return false
    }

    let string_gyms = ""
    let single_gym = ""
    let gyms = $(".gyms input[type='checkbox']")
    for (let i = 0; i < gyms.length; i++) {
        if (gyms[i].checked) {
            string_gyms += gyms[i].name + ","
            single_gym = gyms[i].value
        }
    }

    if (string_gyms.length === 0) {
        alert("You have to select at least one gym")
        return false
    }

    // Request valid, show loading screen
    loading();
    let first_name = username.split(" ")[0];

    // If username is more than 11 characters, use only first name
    if (username.length > 11) {
        $("#name").val(first_name);
    } else {
        $("#name").val(username)
    }

    climb_type = $("#climb-type > .option > input[name='climb-type']:checked").val()
    grading_system = $("#grading-system-" + climb_type + " > div > input[name='grading-system']:checked").val()

    // Set cookie to expire in 30 minutes
    let date = new Date();
    date.setTime(date.getTime() + (30*60*1000));
    let expires = "expires="+ date.toUTCString();

    document.cookie = "climb_type=" + climb_type + ";" + expires + ";path=/;";
    document.cookie = "grading_system=" + grading_system + ";" + expires + ";path=/;";
    document.cookie = "gyms=" + string_gyms.slice(0,-1) + ";" + expires + ";path=/;";
    document.cookie = "uid=" + uid + ";" + expires + ";path=/;";
    document.cookie = "name=" + first_name + ";" + expires + ";path=/;";
    if ($("#remember-me > input").is(":checked")) {
        document.cookie = "remembered=" + username + ":::" + uid + ":::" + gym + ";" + expires + ";path=/;";
    }

    if (string_gyms.slice(0,-1).indexOf(",") !== -1) {
        // In this case, multiple gyms are selected
        document.location.href = "/" + uid
    } else {
        // In this case, only one gym is selected
        document.location.href = "/" + uid + "/" + single_gym
    }

}

function enableRememberMe(){
    $('#remember-me > input').prop('disabled', false).removeClass('remember-me-disabled');
}

function selectRememberedUser(){
    let remembered = $("#remembered-users option:selected").attr("data-id")

    $('#remember-me > input').prop('disabled', true).addClass('remember-me-disabled');

    if (remembered === "none") {
        $("#username-gym").val("Select any gym with tops (last 60 days)")
        $("#username")
            .prepend($('<option>Select a gym first</option>') // Create a new option element
            .prop("disabled", true)
            .prop("selected", true)
            .prop("hidden", true)
            .val(""));

        $("#remembered-users").val("Select a remembered user")

        $("#username-gym").prop('disabled', false)
        $("#username").prop('disabled', true)
    } else {

        $("#username-gym").prop('disabled', true)
        $("#username").prop('disabled', true)

        let rememberedSplit = remembered.split(":::")

        $('#username')
            .prepend($('<option>' + rememberedSplit[0] + '</option>')
            .prop("disabled", true)
            .prop("selected", true)
            .prop("hidden", true)
            .val(rememberedSplit[1]));

        $("#username-gym")
            .prepend($('<option> ' + rememberedSplit[2] + '</option>')
            .prop("disabled", true)
            .prop("selected", true)
            .prop("hidden", true)
            .val(rememberedSplit[3]));

    }
}

function loading(){
    $("#loading").show()
    $("#start-page, #popup").hide();
};

function replaceDirections() {
    if (window.innerWidth <= 1025) {
        $("#direction-1").text("Further down")
        $("#direction-2").text("at the bottom")
    } else {
        $("#direction-1").text("To the right")
        $("#direction-2").text("in the bottom-right corner")
    }
}

async function gymSelected(){
    // Unselect remembered users
    $("#remembered-users").val("Select a remembered user")
    $('#remember-me > input').prop('disabled', true).addClass('remember-me-disabled');

    let usernames = $("#username");
    usernames.addClass("select-loading")

    let gym_id = $("#username-gym option:selected").attr("name");

    // If we have already fetched this gym, just use the cached data
    if (gym_id in gymsFetched) {
        var usersThisGym = gymsFetched[gym_id]
    } else {
        var usersThisGym = await fetchGymUsers(gym_id)
    }

    if (usersThisGym.length == 0) {
        gymsFetched[gym_id] = [];
        $("#username").empty();
        $("#username")
            .prepend($('<option>Select a gym first</option>')
            .prop("selected", true)
            .prop("hidden", true)
            .val(""));
        $("#username").prop('disabled', true)

        usernames.removeClass("select-loading")
        alert("We couldn't find users, please select another gym")
        return;
    }

    fillUsernames(usersThisGym);
    gymsFetched[gym_id] = usersThisGym;
    usernames.removeClass("select-loading")
}

function fillUsernames(users) {

    // sort the users alphabetically, case insensitive, name is only the first elements

    users.sort((a, b) => a[1].localeCompare(b[1], undefined, {sensitivity: 'base'}));

    let select = $("#username");
    select.prop('disabled', false);
    select.empty();
    select.append("<option selected disabled>Select your username</option>");

    for (let i = 0; i < users.length; i++) {
        select.append("<option value='" + users[i][0] + "'>" + users[i][1] + "</option>");
    }
}

function fetchGymUsers(gym_id, climb_type) {

    // Defining the url
    const url = "/api/users/" + gym_id;

    // Fetching the data
    return fetch(url)
        .then(response => response.ok ? response.json() : [])
        .catch(function(error) {
            return [];
        });
}

function preloadGyms() {
    const uid = $("#username > option:selected").val()
    const username = $("#username > option:selected").text().trim();
    const climb_type = $("#climb-type > .option > input[name='climb-type']:checked").val()
    const gym_ids = $(".gyms input[type='checkbox']:checked").map(function() {
        return this.name;
    }).get()

    if (username === "Select a gym first" || username === "Select your username") {
        return
    } else if (uid.length !== 10 || isNaN(uid)) {
        return
    }

    if (gym_ids.length === 0) {
        return
    }

    return fetch("/api/preload/" + uid, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
            "climb_type": climb_type,
            "gym_ids": gym_ids,
            fp: $("#preload").attr("data-id")})
        })
}

$(document).ready(function($){
     $('.gym_search').on('keyup keydown keypress', textGymSearch);
     $("#climb-type").on("change", "input[type='radio']", switchClimbType);
     $("#da-button").on("click", mainFormSubmit);
     replaceDirections()
     window.addEventListener("resize", replaceDirections);
     $("#remembered-users").on("change", selectRememberedUser);
     $("#remembered-users").on("change", preloadGyms);
     $("#username").on("change", enableRememberMe);
     $("#username").on("change", preloadGyms);
     $("#username-gym").on("change", gymSelected);
     $(".gyms input[type='checkbox']:not(:checked)").on("change", preloadGyms);
});