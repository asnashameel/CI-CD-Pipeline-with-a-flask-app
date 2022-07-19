# CI-CD-Pipeline

Project goals: 
1. Build a web automation server using IAC. And also make it available via a public URL
2. You set global configuration (Java, Maven, Git)
3. Create Jenkins User for all students from QA. Restrict permission up to creating a job and configuring a job.
4. QA Eng will create a WebAutomationTestJob in Jenkin by using their own automation framework repo from GitHub. And be able to run that job by schedule.
5. DevOps - WebHook - If there is any commit in the GitHub web automation framework repo a jenkin test job shall run.
6. Use the same automation service for building hrmps applications.
7. Put packages/artifactes into s3
8. Deploy in a dev server. - ui-test
9. Deploy in qa - ui-test
10. Deploy. prod - ui-test