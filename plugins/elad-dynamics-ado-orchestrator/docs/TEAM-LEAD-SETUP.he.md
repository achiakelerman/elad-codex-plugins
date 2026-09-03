# מדריך לראש צוות: ELAD Dynamics Orchestrator

המסמך מסביר איך לחבר את הפלאגין, להגדיר פרויקט Dynamics 365, ולתת ל־Codex לעבוד על משימות הצוות בצורה אוטומטית ומבוקרת.

## 1. תנאים מוקדמים

ראש הצוות צריך:

- Codex Desktop מותקן ומחובר לחשבון הארגוני.
- הרשאת קריאה וכתיבה לפרויקט ול־repository הרלוונטיים ב־Azure DevOps.
- גישה לסביבת Dataverse מסוג Development בלבד.
- תיקיית קוד מקומית שהיא Git repository עם remote בשם `origin`.
- Git, Node.js עם `npx`, .NET SDK ו־Power Platform CLI (`pac`).
- הרשאת גישה ל־GitHub הפרטי של ELAD.

אין לשמור PAT, סיסמאות, client secrets או cookies בקובץ הפרויקט. הם מגיעים דרך authentication של Codex או משתני סביבה.

## 2. חיבור הפלאגין

ב־PowerShell מריצים פעם אחת:

```powershell
codex plugin marketplace add achiakelerman/elad-codex-plugins
```

לאחר מכן:

1. מפעילים מחדש את Codex.
2. פותחים את Plugin Directory.
3. מתקינים את `ELAD Dynamics Orchestrator` מתוך `ELAD Codex Plugins`.
4. פותחים task חדש.

ב־task החדש כותבים:

```text
Use ELAD Dynamics Orchestrator to onboard this Dynamics project before implementation.
```

הפלאגין יישאר במצב `setup-required` עד שכל הפרטים והבדיקות הראשוניות יושלמו.

## 3. הגדרת הפרויקט

אפשר לבצע setup דרך ה־wizard מתוך עותק הריפו של ה־Marketplace:

```powershell
pwsh .\plugins\elad-dynamics-ado-orchestrator\scripts\windows\Initialize-ProjectContext.ps1 -ProjectPath C:\path\to\dynamics-repository
```

או לבקש מהפלאגין לבצע את ה־onboarding בתוך תיקיית הקוד של הפרויקט.

ה־setup יבקש את הפרטים הבאים:

- Azure DevOps: organization, project, repository, branch בסיסי ותג trigger.
- Git: נתיב הקוד וכתובת ה־GitHub remote.
- Dynamics: כתובת סביבת Development, solution unique name, publisher prefix ונתיבי deployment.
- QA: כתובת אפליקציית Dynamics, מצב `playwright` או `manual`, ונתיב Playwright אם קיים.
- סוגי עבודה: `plugin-csharp`, `javascript-webresource`, `configuration` או `mixed`.
- מדיניות עבודה: אוטומטית, ללא פעולות מחיקה.
- מדיניות מודלים: `balanced`, `economy` או `quality`.

הקובץ שנוצר הוא:

```text
<project-root>\.elad\project-context.json
```

הקובץ אישי לפרויקט, לא מכניסים אותו ל־Git, ולא מעתיקים לתוכו credentials.

## 4. התאמות חשובות

ההגדרות נמצאות ב־`.elad/project-context.json` של הפרויקט:

- `ado.triggerTag`: אילו work items האוטומציה רשאית לקחת.
- `ado.defaultBranch`: branch הבסיס שממנו נוצרת כל משימה חדשה.
- `deployment.pluginProjectPath`: נתיב פרויקט ה־C# אם יש plugins.
- `deployment.webResourceRoot`: תיקיית JavaScript/web resources אם יש כאלה.
- `qa.mode`: ברירת המחדל היא Playwright; `manual` מותר כאשר authentication חוסם דפדפן.
- `workflow.enabledTaskTypes`: סוגי המשימות שהצוות מפעיל.
- `workflow.executionMode`: ברירת המחדל היא `automatic`.
- `workflow.deletionPolicy`: חייב להישאר `deny`.
- `workflow.requireLocalValidationBeforeCloud`: חייב להישאר `true`.
- `workflow.requireQaBeforeGithubPush`: חייב להישאר `true`.

הפלאגין עובד רק מול סביבת Dataverse שמסומנת `development`. אין להגדיר סביבת Production.

## 5. MCP והרשאות

הפלאגין כולל MCP עבור Azure DevOps ו־Dataverse. החיבור משתמש בערכים הבאים, לפי מנגנון האימות שאושר בארגון:

```text
AZDO_ORG_SERVICE_URL
AZDO_PAT
AZDO_DEFAULT_PROJECT
DATAVERSE_URL
DATAVERSE_TENANT_ID
```

לאחר ההגדרה מפעילים את בדיקת היכולות. היא מפיקה:

```text
<project-root>\.elad\orchestrator-runs\capability_report.json
```

הדוח חייב לכלול Git, Node/npx, .NET, PAC CLI, שני שרתי ה־MCP וה־agents הרלוונטיים לסוגי העבודה שנבחרו.

## 6. איך העבודה מתבצעת

כאשר יש work item עם תג ה־trigger:

1. ה־orchestrator קורא את ה־ADO item במלואו.
2. הוא מבצע Git preflight ומתחיל מ־`origin/<defaultBranch>`, ללא הסתמכות על branch מקומי קיים.
3. הוא מסווג את המשימה וסורק את הפתרון לפני שינוי.
4. הוא בוחר specialist מתאים: plugin, JavaScript, configuration או mixed.
5. הוא מריץ בדיקות מקומיות.
6. רק לאחר הצלחה הוא מבצע deployment ל־Dataverse Development.
7. הוא מריץ QA ב־Playwright או QA ידני מתועד.
8. רק לאחר QA מוצלח הוא מבצע push ל־GitHub ומעדכן את ADO ל־Testing.

אין אוטומציה למחיקת רכיבי solution, plugin steps, registrations, web resources או קבצים.

## 7. חיסכון בעלויות מודלים

בפרופיל `balanced`:

- `routine`: intake, סיווג, Git preflight, חיפוש ממוקד ודוחות קצרים.
- `strategic`: תכנון, דרישות עמומות, בחירת assembly, deployment והחלטת QA.
- `execution`: מימוש ממוקד לאחר שהתכנון ננעל.

כאשר Codex תומך ב־handoff עם בחירת מודל, ה־orchestrator משתמש ב־tier המתאים. כאשר אין אפשרות להחליף מודל בתוך task, הוא מתעד `routingMode: advisory` ומצמצם את כמות ההקשר וה־prompts.

## 8. יצירת אוטומציה

לאחר שהפרויקט במצב `ready`, יוצרים Automation עם prompt קצר זה:

```text
Use ELAD Dynamics Orchestrator for this project only. On every run, read the ready project context, find active Azure DevOps work items with the configured trigger tag, process one item at a time, start from the configured remote base branch, inspect the relevant solution before coding, run local validation before any cloud operation, deploy only to Dataverse Development, perform Playwright or documented manual QA, and update ADO to Testing only after deployment and QA evidence pass. Do not delete anything and do not push or deploy when a required gate fails.
```

מומלץ להתחיל בתדירות נמוכה, לבדוק מספר משימות, ורק לאחר שההתנהגות יציבה להגדיל את התדירות.

## 9. בדיקת הצלחה ראשונה

לפני הפעלת עבודה אמיתית, ראש הצוות צריך לוודא:

- סטטוס הפרויקט הוא `ready`.
- `capability_report.json` עבר.
- Git preflight יצר branch חדש מ־`origin/master`.
- בדיקה מקומית נכשלת חוסמת deployment.
- QA שנכשל משאיר את ה־ADO item מחוץ ל־Testing.
- אין credentials או נתוני לקוח ב־Git.

אם ה־setup נכשל, אין להתחיל קידוד. מתקנים את השדה או היכולת שמופיעים בדוח ומריצים onboarding מחדש.
