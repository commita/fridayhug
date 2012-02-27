$.facebox.settings.closeImage = '../images/closelabel.png'
$.facebox.settings.loadingImage = '../images/loading.gif'

jQuery(document).ready(function($) {
  $('a[rel*=facebox]').facebox()
})
