<?php

// $Id: standard.profile,v 1.2 2010/07/22 16:16:42 dries Exp $

/**
 * Implements hook_form_FORM_ID_alter().
 *
 * Allows the profile to alter the site configuration form.
 */
function website_form_install_configure_form_alter(&$form, $form_state) {
  // Pre-populate the site name with the server name.
  $form['site_information']['site_name']['#default_value'] = $_SERVER['SERVER_NAME'];
}

/**
 * Implements hook_fb_social_default_presets
 * @return stdClass 
 */
function website_fb_social_default_presets() {
  $export = array();
  $fb_social_preset = new stdClass;
  $fb_social_preset->disabled = FALSE; /* Edit this to true to make a default fb_social_preset disabled initially */
  $fb_social_preset->api_version = 1;
  $fb_social_preset->name = 'fb_like_basic';
  $fb_social_preset->description = 'Provides a like button for the basic content types, Article, Basic page, Poll.';
  $fb_social_preset->plugin_type = 'like';
  $fb_social_preset->settings = array(
    'node_types' => array(
      'types' => array(
        'article' => 'article',
        'page' => 'page',
        'poll' => 'poll',
        'webform' => 0,
      ),
    ),
    'opengraph_tags' => 1,
    'plugin_location' => array(
      'location' => '1',
      'display_teasers' => 1,
    ),
    'block' => 1,
  );
  $fb_social_preset->fb_attrs = array(
    'send' => 1,
    'layout' => 'standard',
    'show_faces' => 1,
    'width' => '350',
    'action' => 'like',
    'font' => 'verdana',
    'colorscheme' => 'light',
  );
  $export['fb_like_basic'] = $fb_social_preset;

  return $export;
}

function website_page_alter(&$page) {
  if (module_exists('fb_social_like')) {
    global $language;

    $languages = _map_active_languages();

    if (fb_social_auto_language ()) {
      if (array_key_exists($language->language, $languages)) {
        $fb_locale = $languages[$language->language];
      }
      else {
        drupal_set_message("There is no mapping for the current language. Using the default locale.");
      }
    }
    else {
      $fb_locale = variable_get('fb_social_locale', 'en_US');
    }

    $appid = variable_get('fb_social_appid', '');

    $output = '<div id="fb-root-top"></div>';
    $output .= "<script type=\"text/javascript\">
     window.fbAsyncInit = function() {
       FB.init({
         appId: " . drupal_json_encode($appid) . ",
         status: true,
         cookie: true,
         xfbml: true});

         jQuery.event.trigger('fb:init');
     };
     (function() {
       var e = document.createElement('script');
       e.async = true;
       e.src = document.location.protocol + '//connect.facebook.net/" . $fb_locale . "/all.js';
       document.getElementById('fb-root-top').appendChild(e);
     }());
  </script>";

    $page['page_top']['fb_social'] = array(
      '#markup' => $output,
    );
  }
}