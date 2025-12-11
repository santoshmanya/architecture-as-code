workspace "Mastery Tutorial Platform" "C4 model for the Mastery online tutorial platform." {

    model {

        // People
        student = person "Student" "A learner who browses tutorials, enrolls, and tracks progress."
        instructor = person "Instructor" "Creates and manages tutorials on Mastery."
        admin = person "Admin" "Manages users, content, and reports for Mastery."

        // External software systems
        emailSystem = softwareSystem "Email Service" "3rd-party email delivery service (e.g., SendGrid)." {
            tags "External"
        }
        paymentProvider = softwareSystem "Payment Provider" "External payment processing system (e.g., Stripe)." {
            tags "External"
        }
        authProvider = softwareSystem "Auth Provider" "External identity provider issuing tokens (e.g., Auth0, Cognito)." {
            tags "External"
        }

        // Mastery system
        mastery = softwareSystem "Mastery Tutorial Platform" "Online platform where students learn and instructors publish tutorials." {

            // Containers
            webApp = container "Web Application" "Delivers the SPA web UI for all user roles." "React / TypeScript, HTML, CSS"

            api = container "API Application" "Implements business logic and exposes REST/GraphQL APIs." "Java / Spring Boot" {

                // ===== API Layer (Controllers) =====
                authController = component "Auth Controller" "Handles login, logout and token verification endpoints." "Spring REST Controller"
                tutorialController = component "Tutorial Controller" "CRUD endpoints for tutorials, sections and lessons." "Spring REST Controller"
                enrollmentController = component "Enrollment Controller" "Endpoints for enrolling students in tutorials." "Spring REST Controller"
                progressController = component "Progress Controller" "Endpoints for updating and querying learning progress." "Spring REST Controller"
                paymentController = component "Payment Controller" "Endpoints for initiating and verifying payments." "Spring REST Controller"

                // ===== Services (Business Logic) =====
                userService = component "User Service" "Business logic for managing user profiles and roles." "Spring Service"
                tutorialService = component "Tutorial Service" "Business logic for tutorials, sections and lessons." "Spring Service"
                enrollmentService = component "Enrollment Service" "Business logic for enrollments and access rules." "Spring Service"
                progressService = component "Progress Service" "Business logic for recording and retrieving tutorial progress." "Spring Service"
                recommendationService = component "Recommendation Service" "Recommends tutorials based on user activity and history." "Spring Service"
                paymentService = component "Payment Service" "Coordinates payment flows with the external Payment Provider." "Spring Service"

                // ===== Repositories (Data Access) =====
                userRepository = component "User Repository" "CRUD access to users in the relational database." "Spring Data JPA"
                tutorialRepository = component "Tutorial Repository" "CRUD access to tutorials and lessons in the relational database." "Spring Data JPA"
                enrollmentRepository = component "Enrollment Repository" "CRUD access to enrollments in the relational database." "Spring Data JPA"
                progressRepository = component "Progress Repository" "CRUD access to progress entries in the relational database." "Spring Data JPA"

                // ===== Integration Clients =====
                emailClient = component "Email Client" "Wraps the Email Service HTTP API for sending emails." "HTTP client"
                paymentClient = component "Payment Client" "Wraps the Payment Provider HTTP API." "HTTP client"
                storageClient = component "Storage Client" "Wraps the object storage SDK/API for tutorial media assets." "SDK / HTTP client"

                // ===== Cross-cutting Components =====
                authTokenValidator = component "Auth Token Validator" "Validates JWT/access tokens issued by the Auth Provider." "Library"
                auditLogger = component "Audit Logger" "Writes audit logs for security-sensitive actions." "Library"
                metricsCollector = component "Metrics Collector" "Collects metrics for observability and SRE dashboards." "Library"

                // ===== Component Relationships =====

                // Controllers to services
                authController -> authTokenValidator "Validates access tokens" "Method call"
                authController -> userService "Performs user-related operations" "Method call"

                tutorialController -> tutorialService "Manages tutorials" "Method call"
                enrollmentController -> enrollmentService "Manages enrollments" "Method call"
                progressController -> progressService "Updates/queries progress" "Method call"
                paymentController -> paymentService "Manages payments" "Method call"

                // Services to repositories
                userService -> userRepository "Reads/writes user data" "Method call"
                tutorialService -> tutorialRepository "Reads/writes tutorial data" "Method call"
                enrollmentService -> enrollmentRepository "Reads/writes enrollment data" "Method call"
                progressService -> progressRepository "Reads/writes progress data" "Method call"

                // Services to other services/clients
                tutorialService -> storageClient "Resolves asset URLs" "Method call"
                enrollmentService -> tutorialRepository "Checks tutorial availability" "Method call"
                enrollmentService -> paymentService "Initiates payment for paid tutorials" "Method call"

                progressService -> tutorialRepository "Gets tutorial lesson counts" "Method call"
                progressService -> emailClient "Sends milestone progress emails" "Method call"

                recommendationService -> tutorialRepository "Reads tutorial catalog" "Method call"
                recommendationService -> progressRepository "Reads user progress history" "Method call"

                paymentService -> paymentClient "Calls Payment Provider APIs" "Method call"

                // Integration clients to external/internal elements
                emailClient -> emailSystem "Sends emails through external provider" "HTTPS/REST"
                authTokenValidator -> authProvider "Validates or introspects tokens" "HTTPS/REST"

                // Cross-cutting: controllers emit audit logs and metrics
                authController -> auditLogger "Emits audit events" "Method call"
                tutorialController -> auditLogger "Emits audit events" "Method call"
                enrollmentController -> auditLogger "Emits audit events" "Method call"
                progressController -> auditLogger "Emits audit events" "Method call"
                paymentController -> auditLogger "Emits audit events" "Method call"

                authController -> metricsCollector "Emits metrics" "Method call"
                tutorialController -> metricsCollector "Emits metrics" "Method call"
                enrollmentController -> metricsCollector "Emits metrics" "Method call"
                progressController -> metricsCollector "Emits metrics" "Method call"
                paymentController -> metricsCollector "Emits metrics" "Method call"
            }

            backgroundWorker = container "Background Worker" "Executes asynchronous jobs such as scheduled emails and report generation." "Java / Spring Boot Worker"

            relationalDb = container "Relational Database" "Stores users, tutorials, enrollments and progress." "PostgreSQL" {
                tags "Database"
            }

            objectStorage = container "Object Storage" "Stores tutorial videos, images, and other large assets." "S3-compatible object store" {
                tags "Storage"
            }

            messageQueue = container "Message Queue" "Carries events and jobs between the API Application and the Background Worker." "Kafka / RabbitMQ / SQS" {
                tags "Queue"
            }
        }

        // ===== Container-level Relationships =====

        student -> webApp "Uses to browse and complete tutorials" "HTTPS"
        instructor -> webApp "Uses to create and manage tutorials" "HTTPS"
        admin -> webApp "Uses to administer Mastery" "HTTPS"

        webApp -> api "Makes API calls" "HTTPS/JSON"
        webApp -> authProvider "Redirects browser for login and logout" "OpenID Connect"

        api -> relationalDb "Reads from and writes to" "JDBC"
        api -> objectStorage "Stores and retrieves tutorial assets" "HTTPS/S3 API"
        api -> messageQueue "Publishes background jobs (emails, reports, analytics)" "AMQP/HTTPS"

        backgroundWorker -> messageQueue "Consumes background jobs" "AMQP/HTTPS"
        backgroundWorker -> emailSystem "Sends scheduled/bulk emails" "HTTPS/REST"

        api -> authProvider "Validates tokens and obtains user identity" "OpenID Connect / OAuth2"
        api -> paymentProvider "Initiates and verifies payments" "HTTPS/REST"

        emailSystem -> api "Sends webhooks (bounces, opens, etc.) [optional]" "HTTPS/JSON"
    }

    views {

        // ===== System Context View =====
        systemContext mastery "SystemContext" "System context diagram for the Mastery Tutorial Platform." {
            include *
        }

        // ===== Container View =====
        container mastery "Containers" "Container diagram for the Mastery Tutorial Platform." {
            include *
        }

        // ===== Component View for API Application =====
        component api "APIComponents" "Component diagram for the Mastery API Application." {
            include *
        }

        // ===== Dynamic View: Lesson completion and milestone email =====
        dynamic api "LessonCompletionFlow" "Shows how a student completes a lesson and triggers a milestone email." {
            progressController -> progressService "Marks lesson as complete"
            progressService -> progressRepository "Saves progress entry"
            progressService -> tutorialRepository "Checks if tutorial is fully completed"
            progressService -> emailClient "Requests milestone email (if completed)"
            emailClient -> emailSystem "Sends milestone email"
        }

        // ===== Styles =====
        styles {

            element "Person" {
                shape person
                background "#08427b"
                color "#ffffff"
                fontSize 22
            }

            element "Software System" {
                background "#1168bd"
                color "#ffffff"
            }

            element "Container" {
                background "#438dd5"
                color "#ffffff"
            }

            element "Component" {
                background "#85bbf0"
                color "#000000"
            }

            element "Database" {
                shape cylinder
            }

            element "Storage" {
                shape cylinder
            }

            element "Queue" {
                shape pipe
            }

            element "External" {
                background "#999999"
                color "#ffffff"
                border dashed
            }
        }
    }
}
