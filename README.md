sddm_wynn theme
===============

A flexible, configurable, material SDDM theme.  Most values are configurable via
the theme.conf file.

Features:
- [x] Select user via user picker
- [x] Select user via typing in username (optional)
- [x] Display organization logo instead of user icon (optional)
- [x] Select background image (configuration option)
- [x] Customizable color scheme (configuration option)
- [x] Set default session (configuration option)
- [x] User selects current session via menu
- [x] Select user's session via request to your API (optional)
- [x] Display a configurable usage message to the user (optional)

## Screenshots (some functionality not shown)

![Screenshot](screenshot.png)

## Configuration file values

You can create a `theme.conf.user` file which will override the defaults.

* `default_background`: Path to background image
* `default_session`: Session name to default to.  This is the `sessionname` in
  `/usr/share/xsessions/sessionname.desktop` (i.e. `cinnamon` or `cinnamon2d`,
  NOT `Cinnamon (Software Rendering)`)
* `accent1`: The color of the top bar
* `accent2`: The color of other items, like the "LOG IN" button
* `accent2_hover`: The color that will be applied on hover to accent2 items
* `logo` (optional): Path to the image that will be placed in the spot usually
  filled by a face icon
* `user_name`: `fill` to have the user fill in their own username, or `select`
  if you would like to provide a menu of users to choose from
* `session_api` (optional): A url which will return the user's preferred
  desktop environment (yes, this was made with a very specific use-case in
  mind)
* `aup` (optional): A string that will contain an Acceptable Use Policy for
  your users.  Escape characters such as '\n' will render properly (i.e. as
  actual newlines).

### Session API

The session API value is useful if, for example, you are running a linux lab of
many users, and users can choose a desktop environment to be associated with
their account.  This could be done via LDAP and an small API.

The greeter theme will read your `session_api` value from the configuration
file, replace `%s` with the username, perform an HTTP `GET` request, and use the
body of the result as the session name.  Again, the session name should be the
`sessionname` in `/usr/share/xsessions/sessionname.desktop` (i.e. `cinnamon` or
`cinnamon2d`, NOT `Cinnamon (Software Rendering)`).  If the API returns `N`,
then it will reset to the `default_session` configuration value.

For example, if your `session_api` is `http://ldap-api.mylab.com/%s/session/0`
and a user types in their name `m_wynn` into the username box, as soon as they
focus away from the username box, the theme will `GET`
`http://ldap-api.mylab.com/m_wynn/session/0`.  If the result is `N`, the
`default_session` will be used.  Otherwise, the body of the response is used as
the session name.
