Flutter Common Widgets
====================
MaterialApp            // Root widget for Material Design apps
Scaffold               // Basic layout structure (app bar, body, etc.)
AppBar                 // Top app bar with title and actions
ListView               // Scrollable list of widgets
Text                   // Displays a string of text
Container              // Box for layout, styling, and positioning
Row                    // Arranges children horizontally
Column                 // Arranges children vertically
ElevatedButton         // Material-styled button with elevation
TextButton             // Flat Material-styled button
FloatingActionButton   // Circular button floating above content
Image.network          // Displays an image from a URL
Card                   // Material-styled container with elevation
TextField              // Widget for user text input

MaterialApp Properties (Flutter)
===============================
1- key                  // Unique identifier for the widget
2- title                // Title for the app (used by the OS)
3- color                // The color of the app window
4- theme                // The app's ThemeData
5- home                 // The widget for the default route of the app
6- routes               // Map of named route strings to widget builders
7- initialRoute         // The name of the first route to show
8- builder              // Widget builder for wrapping the app
9- navigatorKey         // Key for the app's Navigator

other:
- onGenerateRoute      
- onUnknownRoute    
- navigatorObservers   
- onGenerateTitle  
- darkTheme    
- highContrastTheme  
- highContrastDarkTheme
- themeMode 
- locale  
- localizationsDelegates
- supportedLocales   
- localeResolutionCallback 
- debugShowMaterialGrid
- showPerformanceOverlay
- checkerboardRasterCacheImages 
- checkerboardOffscreenLayers 
- showSemanticsDebugger 
- debugShowCheckedModeBanner  
- shortcuts  
- actions  
- restorationScopeId 


Scaffold Properties (Flutter)
============================

1- key                  // Unique identifier for the widget
2- appBar               // Top app bar (usually an AppBar widget)
3- body                 // Main content area of the screen
4- drawer               // Side navigation panel that slides in from the left
5- floatingActionButton // Circular button floating above the content
6- backgroundColor      // Background color of the entire Scaffold

other:
- floatingActionButtonLocation
- floatingActionButtonAnimator
- persistentFooterButtons
- onDrawerChanged
- endDrawer
- onEndDrawerChanged
- bottomNavigationBar
- bottomSheet
- resizeToAvoidBottomInset
- primary
- extendBody
- extendBodyBehindAppBar
- drawerScrimColor
- drawerEdgeDragWidth
- drawerEnableOpenDragGesture
- endDrawerEnableOpenDragGesture
- restorationId

AppBar Properties (Flutter)
==========================

1- key              // Unique identifier for the AppBar widget
2- leading          // Widget at the start (usually left) of the app bar (back button)
3- title            // Main widget in the center (usually Text)
4- actions          // List of widgets at the end (right) of the app bar
5- bottom           // Widget displayed below the app bar (e.g., AppBar, TabBar)
6- elevation        // Shadow depth below the app bar
7- shadowColor      // Color of the app bar's shadow
8- backgroundColor  // Background color of the app bar
9- foregroundColor  // Default color for text and icons in the app bar

other:
- automaticallyImplyLeading
- flexibleSpace
- shape
- iconTheme
- actionsIconTheme
- primary
- centerTitle
- excludeHeaderSemantics
- titleSpacing
- toolbarOpacity
- bottomOpacity
- toolbarHeight
- leadingWidth
- toolbarTextStyle
- titleTextStyle
- systemOverlayStyle

ListView Properties (Flutter)
===========================
1- key              // Unique identifier for the ListView widget
2- children         // List of widgets to display (for ListView.children)
3- itemBuilder      // Function to build each item (for ListView.builder)
4- itemCount        // Number of items (for ListView.builder)
5- padding          // Space around the list content
6- shrinkWrap       // Whether the list takes only as much space as needed
7- physics          // Scrolling behavior (e.g., bouncing, always scrollable)
8- controller       // Controls and listens to scroll position
9- scrollDirection  // The axis along which the list scrolls (vertical by default)

other:
- scrollDirection
- reverse
- primary
- itemExtent
- prototypeItem
- cacheExtent
- semanticChildCount
- dragStartBehavior
- keyboardDismissBehavior
- restorationId
- clipBehavior

Text Properties (Flutter)
========================
1- key               // Unique identifier for the ListTextView widget
2- data              // The text string to display
3- style             // TextStyle for font, color, size, etc.
4- textAlign         // Alignment within its container
5- maxLines          // Maximum number of lines
6- overflow          // How to handle overflow (clip, ellipsis, fade, etc.)
7- softWrap          // Whether to wrap text at soft line breaks
8- textScaleFactor   // Scaling for accessibility
9- semanticsLabel    // For accessibility

other:
- strutStyle
- textDirection
- locale
- textWidthBasis
- textHeightBehavior

Container Properties (Flutter)
=============================
1- key                  // Unique identifier for the Container widget
2- child                // The single widget inside the container
3- alignment            // How to align the child within the container
4- padding              // Space inside the container, around the child
5- color                // Background color of the container
6- decoration           // Visual decoration (border, gradient, etc.)
7- foregroundDecoration // Decoration drawn in front of the child
8- width                // Container's width
9- height               // Container's height

other:
- constraints
- margin
- transform
- transformAlignment
- clipBehavior

Row / Column Properties (Flutter)
================================
1- key                // Unique identifier for the Row/Column widget
2- children           // List of widgets to arrange in (Row) or in (Column) style.
3- mainAxisAlignment  // How to align children along the main axis (start, center, end, etc)
4- crossAxisAlignment // How to align children along the cross axis (start, center, end, stretch, etc.)
5- mainAxisSize       // Whether the row/column takes minimum or maximum space along the main axis
6- textDirection      // The direction to lay out children (left-to-right or right-to-left)
7- verticalDirection  // The order in which children are laid out vertically (down or up)
8- textBaseline       // Used for aligning text when crossAxisAlignment is baseline

ElevatedButton Properties (Flutter)
==================================
1- key          // Unique identifier for the button widget
2- onPressed    // Callback when the button is tapped (required for enabled state)
3- onLongPress  // Callback when the button is long-pressed
4- child        // The widget below this button, usually a Text or Icon
5- style        // Defines the button's visual appearance (color, shape, etc.)
6- focusNode    // Node for keyboard focus handling
7- autofocus    // Whether the button should be focused initially
8- clipBehavior // How to clip content (e.g., anti-aliasing, hard edge)

TextButton Properties (Flutter)
==============================
1- key          // Unique identifier for the button widget
2- onPressed    // Callback when the button is tapped (required for enabled state)
3- onLongPress  // Callback when the button is long-pressed
4- child        // The widget below this button, usually a Text or Icon
5- style        // Defines the button's visual appearance (color, shape, etc.)
6- focusNode    // Node for keyboard focus handling
7- autofocus    // Whether the button should be focused initially
8- clipBehavior // How to clip content (e.g., anti-aliasing, hard edge)

FloatingActionButton Properties (Flutter)
========================================
1- key                 // Unique identifier for the button widget
2- child               // The widget below this button, usually an Icon
3- onPressed           // Callback when the button is tapped (required for enabled state)
4- tooltip             // Text shown when the user long-presses or hovers over the button
5- foregroundColor     // Color for the button's icon
6- backgroundColor     // Fill color of the button
7- focusColor          // Color when the button is focused
8- hoverColor          // Color when the button is hovered
9- splashColor         // Splash color for tap interactions
10- elevation           // Shadow depth when enabled
11- highlightElevation  // Shadow depth when pressed
12- focusElevation      // Shadow depth when focused
13- hoverElevation      // Shadow depth when hovered

other:
- disabledElevation
- mini
- shape
- clipBehavior
- materialTapTargetSize
- isExtended
- heroTag
- enableFeedback
- autofocus

Image.network Properties (Flutter)
=================================
1- key            // Unique identifier for the image widget
2- src            // The URL of the image to display (required)
3- scale          // Image scale factor (for high-DPI images)
4- width          // Width of the image
5- height         // Height of the image
6- color          // Color to blend with the image
7- colorBlendMode // How to blend the color with the image
8- fit            // How to inscribe the image into the space (BoxFit)
9- alignment      // How to align the image within its bounds

other:
- repeat
- centerSlice
- matchTextDirection
- gaplessPlayback
- filterQuality
- loadingBuilder
- errorBuilder
- semanticLabel
- excludeFromSemantics
- isAntiAlias

Card Properties (Flutter)
========================
1- key                // Unique identifier for the card widget
2- child              // The widget below this card, usually content
3- color              // Background color of the card
4- shadowColor        // Color of the card's shadow
5- elevation          // Shadow depth (z-coordinate) of the card
6- shape              // Shape of the card's border (e.g., rounded corners)
7- margin             // Outer margin around the card
8- clipBehavior       // How to clip content (e.g., anti-aliasing, hard edge)
9- semanticContainer  // Whether the card is a semantic container for accessibility
0- borderOnForeground // Whether to paint the border in front of the child

TextField Properties (Flutter)
=============================
1- key                 // Unique identifier for the text field widget
2- controller          // Controls the text being edited
3- focusNode           // Node for keyboard focus handling
4- decoration          // Visual decoration (label, hint, icon, border, etc.)
5- keyboardType        // Type of keyboard to use (text, number, email, etc.)
6- textInputAction     // Action button on the keyboard (done, next, etc.)
7- textCapitalization  // How to capitalize entered text (none, words, sentences, all)
8- style               // TextStyle for the input text (font, color, size, etc.)
9- strutStyle          // Defines minimum line height, alignment, etc.
10- textAlign           // How to align text horizontally within the field
11- textAlignVertical   // How to align text vertically within the field
12- textDirection       // The direction of the text (LTR or RTL)

other:
- readOnly
- toolbarOptions
- showCursor
- autofocus
- obscuringCharacter
- obscureText
- autocorrect
- smartDashesType
- smartQuotesType
- enableSuggestions
- maxLines
- minLines
- expands
- maxLength
- onChanged
- onEditingComplete
- onSubmitted
- inputFormatters
- enabled
- cursorWidth
- cursorHeight
- cursorRadius
- cursorColor
- selectionHeightStyle
- selectionWidthStyle
- keyboardAppearance
- scrollPadding
- dragStartBehavior
- enableInteractiveSelection
- selectionControls
- onTap
- mouseCursor
- buildCounter
- scrollController
- scrollPhysics
- autofillHints
- clipBehavior
- restorationId
- enableIMEPersonalizedLearning

