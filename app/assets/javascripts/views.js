function initMap () {
  let search_position
  let types = [ 'wifi', 'aircon', 'availsockets', 'coffee', 'quiet', 'uncrowded' ]
  let filterstates = {}
  let all_locations = []
  let shown_locations = []
  let markers = []
  let cookieData = {}

  let map = new google.maps.Map(document.getElementById('listMap'), {
    zoom: 16,
    center: {
      lat: 1.3072052,
      lng: 103.831843
    },
    mapTypeControl: false,
    scaleControl: true,
    streetViewControl: false,
    fullscreenControl: true
  })

  let userLocationInfoWindow = new google.maps.InfoWindow({ map: map })
  let infoWindow = new google.maps.InfoWindow()

  // create a div to hold the geolocate button
  let centerControlDiv = document.createElement('div')
  let centerControl = new CenterControl(centerControlDiv, map)
  map.controls[google.maps.ControlPosition.TOP_CENTER].push(centerControlDiv)

  function CenterControl(controlDiv, map) {
    // set CSS for button border
    let controlUI = document.createElement('div')
      controlUI.setAttribute('id', 'geolocateButton')
      controlUI.setAttribute('class', 'btn btn-info')
      controlDiv.appendChild(controlUI)
    // set CSS for button interior
    let controlText = document.createElement('div')
      controlText.innerHTML = 'Current location'
      controlUI.appendChild(controlText)
    // set up click event listener to geolocate
    controlUI.addEventListener('click', function() {
      geolocate()
    })
  }

  // bias search results for start location in favour of locations in Singapore
  let autocompleteDefaultBounds = new google.maps.LatLngBounds(
    new google.maps.LatLng(1.077484, 103.582585),
    new google.maps.LatLng(1.490568, 104.093450)
  )
  let autocompleteOptions = {
    bounds: autocompleteDefaultBounds
  }

  // set up autocomplete search field and position it at the top edge, horizontally centered
  let pacInput = document.getElementById('pac-input')
  map.controls[google.maps.ControlPosition.TOP_CENTER].push(pacInput)

  let autocomplete = new google.maps.places.Autocomplete(pacInput, autocompleteOptions)
  autocomplete.addListener('place_changed', function () {
    let place = autocomplete.getPlace()
    if (!place.geometry) {
      // display an alert if the user enters the name of a Place that was not suggested and presses the Enter key, or if the Place Details request fails
      window.alert("No details available for input: '" + place.name + "'")
      return
    }
    map.setCenter(place.geometry.location)
    map.setZoom(16)
    userLocationInfoWindow.setPosition(place.geometry.location)
    userLocationInfoWindow.setContent('Your location')
    // send a get request to the controller with the search position as updated by the user, expecting a number of locations in response
    search_position = {
      lat: place.geometry.location.lat(),
      lng: place.geometry.location.lng()
    }
    updateSearchPositionCookie()
    $.ajax({
      type: 'GET',
      url: '/locations/map_view',
      data: search_position,
      contentType: 'application/json',
      dataType: 'json'
    }).done(function (response) {
      all_locations = response
      all_locations.forEach(location => {
        location[ 'availsockets' ] =
          location[ 'available_sockets' ] > 0 ? true : false
        location[ 'uncrowded' ] =
          location[ 'available_seats' ] /
          location[ 'total_seats' ] > 0.3 ? true : false
      updateFiltering()
      })
    })
  })

  // place a marker at each location provided by the controller
  function placeMarker (location) {
    let latLng = new google.maps.LatLng(location[ 'lat' ], location[ 'lng' ])
    let marker = new google.maps.Marker({
      position: latLng,
      map: map,
      icon: {
        url: "marker.png",
        scaledSize: new google.maps.Size(32, 32)
      },
      animation: google.maps.Animation.DROP
    })
    // each time a marker is clicked, open an information window displaying the location name linked to its show view, and send the search position set by the user to the controller along with the request
    google.maps.event.addListener(marker, 'click', function () {
      infoWindow.close()
      let search_position_lat = search_position['lat']
      let search_position_lng = search_position['lng']
      infoWindow.setContent("<div id= 'infoWindow'>" + "<a href='/locations/" + location[ 'id' ] + '/?lat=' + search_position_lat + '&lng=' + search_position_lng + "'>" + location[ 'name' ] + '</a>' + '</div>')
      infoWindow.open(map, marker)
    })
    markers.push(marker)
  }

  // geolocation
  function geolocate () {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(function (position) {
        // send a get request to the controller with the search position as found by geolocation, expecting a number of locations in response
        search_position = {
          lat: position.coords.latitude,
          lng: position.coords.longitude
        }
        userLocationInfoWindow.setPosition(search_position)
        userLocationInfoWindow.setContent('Your location')
        map.setCenter(search_position)
        updateSearchPositionCookie()
        $.ajax({
          type: 'GET',
          url: '/locations/map_view',
          data: search_position,
          contentType: 'application/json',
          dataType: 'json'
        }).done(function (response) {
          all_locations = response
          all_locations.forEach(location => {
            location[ 'availsockets' ] =
              location[ 'available_sockets' ] > 0 ? true : false
            location[ 'uncrowded' ] =
              location[ 'available_seats' ] /
              location[ 'total_seats' ] > 0.3 ? true : false
          })
        updateFiltering()
        })
      }, function () {
        handleLocationError(true, userLocationInfoWindow, map.getCenter())
      })
    } else {
      // Browser doesn't support Geolocation
      handleLocationError(false, userLocationInfoWindow, map.getCenter())
    }
  }



  // if user clicks on 'Current location' button, call the geolocate function
  $('#geolocate').click(function () {
    geolocate()
  })

  // FILTERING CODE


  $(document).ready(function () {
    // adds listeners to each button
    $('#switch-views').click(function () {
      flipView()
    })
    $('.button-morefilters').click(function(){
      toggleMorefiltersButton()
    })
    $('.button-clearfilters').click(function(){
      clearFilters()
    })
    types.forEach(type => {
      $('.button-' + type).click(function () {
        flipFilter(type)
      })
    })
    // loads filters from cookie if cookie exists
    if (document.cookie) cookieData = JSON.parse(document.cookie)
    if (cookieData.filters) filterstates = cookieData.filters
    if (cookieData.search_position) {
      search_position = cookieData.search_position
      $.ajax({
        type: 'GET',
        url: '/locations/map_view',
        data: search_position,
        contentType: 'application/json',
        dataType: 'json'
      }).done(function (response) {
        all_locations = response
        all_locations.forEach(location => {
          location[ 'availsockets' ] =
            location[ 'available_sockets' ] > 0 ? true : false
          location[ 'uncrowded' ] =
            location[ 'available_seats' ] /
            location[ 'total_seats' ] > 0.3 ? true : false
          })
        map.setCenter(search_position)
        userLocationInfoWindow.setPosition(search_position)
        userLocationInfoWindow.setContent('Your location')
        updateFiltering()
        })
    } else
      geolocate()
  })

  $('#listCards').hide()
  function flipView() {
    if ($('#listCards').is(':hidden')) {
      $('#listCards').fadeIn(300)
      $('#listMap').fadeOut(300)
      $('#switch-views').text('Map View')
    } else {
      $('#listCards').fadeOut(300)
      $('#listMap').fadeIn(300)
      $('#switch-views').text('List View')
    }
  }

  // generates cards from shown_locations and updates $listCards
  function updateCards () {
    $('#listCards').empty()
    let cardslist = $('<div></div>')
    shown_locations.forEach(location => {
      let card = $('<div></div>')
      let imagelink = ''
      if (location['cloudinary_link']) { imagelink = `<img src=" ${location['cloudinary_link']} " alt='' class='img-responsive center-block'>` } else {
        imagelink = `<img src="http://placehold.it/300x300" alt="" class='img-responsive center-block'>`
      }
      let walktime = Math.floor(location['distance'] / 40) + 1
      let filtersString = ''

      if ( location[ 'wifi' ] ) filtersString += wifiIcon
      if ( location[ 'aircon' ] ) filtersString += airconIcon
      if ( location[ 'availsockets' ] ) filtersString += socketsIcon
      if ( location[ 'coffee' ] ) filtersString += coffeeIcon
      if ( location[ 'quiet' ] ) filtersString += quietIcon
      if ( location[ 'uncrowded' ] ) filtersString += uncrowdedIcon
      let distance = Math.floor( location[ 'distance' ] )

      let showLinkString = `<a href="/locations/${location['id']}/?lat=${search_position['lat']}&lng=${search_position['lng']}">${location['name']}</a>`
      card.html(
        `
        <div class="well location-card row">
          <div class="col-xs-5 col-md-3 location-card-img hidden-sm hidden-xs">
            ${imagelink}
          </div>
          <div class="col-xs-12 col-md-9 location-card-info">
          <h3>${location['name']}</h3>
          ${location['vicinity']} <br><br>
          <p class="label label-default">${location['available_seats']} seats available</p>
          <p class="label label-default">${location['available_sockets']} sockets available</p>
          <hr>
          <div class='row'>
            ${filtersString}
          </div>
          <hr>
          ${distance} metres away<br>
          ${walktime} min away
          <hr>
          <a href="/locations/${location['id']}/?lat=${search_position['lat']}&lng=${search_position['lng']}"><button class="btn-default btn">View details</button></a>
          </div>
        </div>
        `
      )
      cardslist.append(card)
    })
    $('#listCards').append(cardslist)
  }

  // changes filterstates type
  function flipFilter (type) {
    filterstates[ type ] = filterstates[ type ] === true ? false : true
    updateFiltersCookie()
    updateFiltering()
  }

  // updates the shown_locations array according to the filters
  function updateFiltering () {
    markers.forEach(marker => marker.setMap(null))
    markers = []
    shown_locations = all_locations.slice()
    types.forEach(type => {
      if (filterstates[ type ] === true) {
        $('.button-' + type)
          .removeClass('filter-false')
          .addClass('filter-true')
        shown_locations = shown_locations.filter((location) => {
          return location[ type ] == true
        })
      } else {
        $('.button-' + type)
          .addClass('filter-false')
          .removeClass('filter-true')
      }
    })
    renderShownLocations()
  }

  function updateFiltersCookie() {
    cookieData.filters = filterstates
    document.cookie = JSON.stringify(cookieData)
  }

  function updateSearchPositionCookie() {
    cookieData.search_position = search_position
    document.cookie = JSON.stringify(cookieData)
  }

  // toggle morefilters button
  function toggleMorefiltersButton () {
    if ( $('.button-morefilters').text() === 'more filters' )
      $('.button-morefilters').text('less filters')
    else
      $('.button-morefilters').text('more filters')
  }

  // clears filters and update
  function clearFilters() {
    filterstates = {}
    updateFiltersCookie()
    updateFiltering()
  }

  // toggle filter view
  $('#filter-div').hide()
  $('#filter-toggle').click(() => {
    $('#filter-div').toggle(300)
    let filterToggleText = $('#filter-toggle').text()
    $('#filter-toggle').text(filterToggleText == 'Show Filters' ? filterToggleText = 'Hide Filters' : filterToggleText = 'Show Filters')
  })

  // updates both the map markers and the cards
  function renderShownLocations () {
    // add markers to map
    shown_locations.forEach(location => placeMarker(location))
      // update cards
    updateCards()
  }
}

function handleLocationError (browserHasGeolocation, userLocationInfoWindow,
  search_position) {
  userLocationInfoWindow.setPosition(search_position)
  userLocationInfoWindow.setContent(browserHasGeolocation ?
    'Error: Please allow your Geolocation service.' :
    'Error: Your browser doesn\'t support geolocation.')
}
