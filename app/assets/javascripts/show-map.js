function initMap () {
  var map = new google.maps.Map(document.getElementById('showMap'), {
    zoom: 16,
    center: {
      lat: 1.3072052,
      lng: 103.831843
    },
    scaleControl: true,
    fullscreenControl: true
  })
  var markerArray = []
  var stepDisplay = new google.maps.InfoWindow()
  function attachInstructionText (stepDisplay, marker, text, map) {
    google.maps.event.addListener(marker, 'click', function () {
      stepDisplay.setContent(text)
      stepDisplay.open(map, marker)
    })
  }
  function showSteps (directionResult, markerArray, stepDisplay, map) {
    for (var i = 0; i < markerArray.length; i++) {
      markerArray[i].setMap(null)
    }
    var myRoute = directionResult.routes[0].legs[0]
    for (var j = 0; j < myRoute.steps.length; j++) {
      var marker = markerArray[j] = markerArray[j] || new google.maps.Marker()
      marker.setMap(map)
      marker.setPosition(myRoute.steps[j].start_location)
      attachInstructionText(stepDisplay, marker, myRoute.steps[j].instructions, map)
    }
  }
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function (position) {
      var pos = {
        lat: position.coords.latitude,
        lng: position.coords.longitude
      }
      map.setCenter(pos)
      var coords = new google.maps.LatLng(pos)
      var directionsService = new google.maps.DirectionsService()
      var directionsDisplay = new google.maps.DirectionsRenderer()
      directionsDisplay.setMap(map)
      var request = {
        origin: coords,
        destination: destinationLatLng,
        travelMode: google.maps.DirectionsTravelMode.WALKING
      }

      directionsService.route(request, function (response, status) {
        if (status == google.maps.DirectionsStatus.OK) {
          directionsDisplay.setDirections(response)
          showSteps(response, markerArray, stepDisplay, map)
        }
      })
    })
  }
}
