function confirmDelete(e){return confirm(e)}function confirmDeletePhoto(e){var o=confirm("Are you sure you want to delete your profile photo?");return o?void load_user_photo(1,e):($("#delete_photo").removeAttr("checked"),!1)}function load_user_photo(e,o){$.ajax({url:"/users/"+o+"/get_user_profile_photo?is_delete="+e,type:"GET",success:function(e){$("#user_photo").html(e)}})}