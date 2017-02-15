function initMap () {
  var user_lat
  var user_lng
  var map = new google.maps.Map(document.getElementById('listMap'), {
    zoom: 16,
    center: {lat: 1.3072052, lng: 103.831843}
  })
  var infoWindow = new google.maps.InfoWindow()
  function placeMarker (location) {
    var latLng = new google.maps.LatLng(location['lat'], location['lng'])
    var marker = new google.maps.Marker({
      position: latLng,
      map: map
    })
    google.maps.event.addListener(marker, 'click', function () {
      infoWindow.close()
      infoWindow.setContent("<div id= 'infoWindow'>" + "<a href='/locations/" + location['id'] + "'>" + location['name'] + '</a>' + '</div>')
      infoWindow.open(map, marker)
    })
  };
  var userLocationInfoWindow = new google.maps.InfoWindow({map: map})
  // Try HTML5 geolocation.
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function (position) {
      user_lat = position.coords.latitude
      user_lng = position.coords.longitude
      $('#get_list_view').click(function () {
        window.location.href = '/locations/list_view/?lat=' + user_lat + '&lng=' + user_lng
      })
      var pos = {
        lat: position.coords.latitude,
        lng: position.coords.longitude
      }
      userLocationInfoWindow.setPosition(pos)
      userLocationInfoWindow.setContent('Your location')
      map.setCenter(pos)
      $.ajax({
        type: 'GET',
        url: '/locations/map_view',
        data: pos,
        contentType: 'application/json',
        dataType: 'json'
      }).done(function (response) {
        response.forEach(function (element) {
          placeMarker(element)
        })
      })
    }, function () {
      handleLocationError(true, userLocationInfoWindow, map.getCenter())
    })
  } else {
    // Browser doesn't support Geolocation
    handleLocationError(false, userLocationInfoWindow, map.getCenter())
  };
}
function handleLocationError (browserHasGeolocation, userLocationInfoWindow, pos) {
  userLocationInfoWindow.setPosition(pos)
  userLocationInfoWindow.setContent(browserHasGeolocation ?
    'Error: Please allow your Geolocation service.' :
    'Error: Your browser doesn\'t support geolocation.')
}
