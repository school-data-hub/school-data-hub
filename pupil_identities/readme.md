### Pupil identities


#### In development

In this folder you can find the file `fake_pupil_identities.txt`. These identities are fake and were partly generated with https://www.fakenamegenerator.com/ .

You can use this file to populate an environment. To do that, start the windows version of the app and import the pupils using the button "Daten aus SchiLD importieren" in the "Scan-tools" main menu page.

#### In production

If your school is in NRW (Germany), you can use `schuldaten_hub_schild_vorlage.txt` as a template with the official school administrative software "SchiLD" to export the pupil identities.

You can also find the data structure for the import file here: https://github.com/school-data-hub/school-data-hub/blob/main/frontend/lib/features/pupil/domain/models/pupil_data.dart

In the txt file, every line is a data set, and the fields are separated by commas.
