# ``noetsi/Note``

Represents the essential data type of the application - a Note.

## Overview

Each ``Note`` and has a ``title``, ``body`` and ``tags``. Its theme is composed of a ``Pattern`` and a background ``color``.
Currently supported attachments are ``Note/checklist``s and ``Note/reminder``s.

## Topics

### Text fields
- ``Note/title``
- ``Note/body``
- ``Note/tags``

### Text helpers
- ``Note/bodyCompact``
- ``Note/bodyInline``
- ``Note/shareable``
- ``Note/description``

### Theme
- ``Note/color``
- ``Note/pattern``

### Note attachments
- ``Note/checklist``
- ``Note/reminder``

### Additional information
- ``Note/timestamp``
- ``Note/isEmpty``

### Instance Methods
- ``Note/encode(to:)``
- ``Note/copy()``

### Initializers
- ``Note/init()``
- ``Note/init(id:)``
- ``Note/init(from:)``
- ``Note/init(id:title:body:tags:timestamp:color:pattern:checklist:notificationRequest:)``
