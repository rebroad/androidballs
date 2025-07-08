#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
#include <android/log.h>
#include <math.h>

#define LOG_TAG "PhysicsDemo"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

#define NUM_BALLS 6
#define GRAVITY 0.3f
#define FRICTION 0.99f
#define BOUNCE 0.8f

typedef struct {
    float x, y;
    float vx, vy;
    float radius;
    int r, g, b;
} PhysicsBall;

static PhysicsBall balls[NUM_BALLS];
static float accel_x = 0, accel_y = 0;
static float gyro_x = 0, gyro_y = 0;

// Initialize physics balls
static void init_balls(int screen_w, int screen_h) {
    for (int i = 0; i < NUM_BALLS; i++) {
        balls[i].x = (float)(SDL_rand(screen_w / 2) + screen_w / 4);
        balls[i].y = (float)(SDL_rand(screen_h / 2) + screen_h / 4);
        balls[i].vx = (float)(SDL_rand(100) - 50) / 25.0f;
        balls[i].vy = (float)(SDL_rand(100) - 50) / 25.0f;
        balls[i].radius = 40.0f;

        // Use distinct colors
        switch (i % 6) {
            case 0: balls[i].r = 255; balls[i].g = 100; balls[i].b = 100; break; // Red
            case 1: balls[i].r = 100; balls[i].g = 255; balls[i].b = 100; break; // Green
            case 2: balls[i].r = 100; balls[i].g = 100; balls[i].b = 255; break; // Blue
            case 3: balls[i].r = 255; balls[i].g = 255; balls[i].b = 100; break; // Yellow
            case 4: balls[i].r = 255; balls[i].g = 100; balls[i].b = 255; break; // Magenta
            case 5: balls[i].r = 100; balls[i].g = 255; balls[i].b = 255; break; // Cyan
        }
    }
}

// Check collision between two balls and resolve it
static void resolve_ball_collision(PhysicsBall *ball1, PhysicsBall *ball2) {
    float dx = ball2->x - ball1->x;
    float dy = ball2->y - ball1->y;
    float distance = sqrtf(dx * dx + dy * dy);
    float min_distance = ball1->radius + ball2->radius;

    if (distance < min_distance && distance > 0.0f) {
        // Normalize collision vector
        float nx = dx / distance;
        float ny = dy / distance;

        // Separate balls to prevent overlap
        float overlap = min_distance - distance;
        float separation_x = nx * overlap * 0.5f;
        float separation_y = ny * overlap * 0.5f;

        ball1->x -= separation_x;
        ball1->y -= separation_y;
        ball2->x += separation_x;
        ball2->y += separation_y;

        // Calculate relative velocity
        float relative_vx = ball2->vx - ball1->vx;
        float relative_vy = ball2->vy - ball1->vy;

        // Calculate velocity along collision normal
        float velocity_along_normal = relative_vx * nx + relative_vy * ny;

        // Only resolve collision if balls are moving toward each other
        if (velocity_along_normal < 0) {
            // For equal mass balls, simply swap velocities along collision normal
            float restitution = BOUNCE;

            // Calculate new velocities along normal
            float v1_normal = ball1->vx * nx + ball1->vy * ny;
            float v2_normal = ball2->vx * nx + ball2->vy * ny;

            // Swap and apply restitution
            float new_v1_normal = v2_normal * restitution;
            float new_v2_normal = v1_normal * restitution;

            // Update velocities
            ball1->vx += (new_v1_normal - v1_normal) * nx;
            ball1->vy += (new_v1_normal - v1_normal) * ny;
            ball2->vx += (new_v2_normal - v2_normal) * nx;
            ball2->vy += (new_v2_normal - v2_normal) * ny;
        }
    }
}

// Update physics
static void update_physics(int screen_w, int screen_h, float delta_time) {
    for (int i = 0; i < NUM_BALLS; i++) {
        PhysicsBall *ball = &balls[i];

        // Apply gravity based on phone orientation
        float gravity_x = -accel_x * GRAVITY;
        float gravity_y = accel_y * GRAVITY;

        // Apply gyroscope rotation (gentler)
        ball->vx -= gyro_y * delta_time * 0.05f;
        ball->vy += gyro_x * delta_time * 0.05f;

        // Apply gravity
        ball->vx += gravity_x;
        ball->vy += gravity_y;

        // Apply friction
        ball->vx *= FRICTION;
        ball->vy *= FRICTION;

        // Update position
        ball->x += ball->vx;
        ball->y += ball->vy;

        // Bounce off walls
        if (ball->x - ball->radius < 0) {
            ball->x = ball->radius;
            ball->vx = -ball->vx * BOUNCE;
        } else if (ball->x + ball->radius > screen_w) {
            ball->x = screen_w - ball->radius;
            ball->vx = -ball->vx * BOUNCE;
        }

        if (ball->y - ball->radius < 0) {
            ball->y = ball->radius;
            ball->vy = -ball->vy * BOUNCE;
        } else if (ball->y + ball->radius > screen_h) {
            ball->y = screen_h - ball->radius;
            ball->vy = -ball->vy * BOUNCE;
        }

        // Keep balls on screen
        if (ball->x < ball->radius) ball->x = ball->radius;
        if (ball->x > screen_w - ball->radius) ball->x = screen_w - ball->radius;
        if (ball->y < ball->radius) ball->y = ball->radius;
        if (ball->y > screen_h - ball->radius) ball->y = screen_h - ball->radius;
    }

    // Check ball-to-ball collisions
    for (int i = 0; i < NUM_BALLS; i++) {
        for (int j = i + 1; j < NUM_BALLS; j++) {
            resolve_ball_collision(&balls[i], &balls[j]);
        }
    }
}

// Draw physics balls
static void draw_balls(SDL_Renderer *renderer) {
    for (int i = 0; i < NUM_BALLS; i++) {
        PhysicsBall *ball = &balls[i];

        // Draw filled circle
        SDL_SetRenderDrawColor(renderer, ball->r, ball->g, ball->b, 255);

        int radius = (int)ball->radius;
        int center_x = (int)ball->x;
        int center_y = (int)ball->y;

        // Draw circle using points
        for (int dx = -radius; dx <= radius; dx += 2) {
            for (int dy = -radius; dy <= radius; dy += 2) {
                if (dx*dx + dy*dy <= radius*radius) {
                    SDL_RenderPoint(renderer, center_x + dx, center_y + dy);
                }
            }
        }
    }
}

// Handle sensor events
static void handle_sensor_event(SDL_SensorEvent *event) {
    SDL_Sensor *sensor = SDL_GetSensorFromID(event->which);
    if (!sensor) return;

    SDL_SensorType type = SDL_GetSensorType(sensor);
    switch (type) {
        case SDL_SENSOR_ACCEL:
            accel_x = event->data[0];
            accel_y = event->data[1];
            LOGI("Accel: %.2f, %.2f", accel_x, accel_y);
            break;
        case SDL_SENSOR_GYRO:
            gyro_x = event->data[0];
            gyro_y = event->data[1];
            LOGI("Gyro: %.2f, %.2f", gyro_x, gyro_y);
            break;
        default:
            break;
    }
}

int main(int argc, char *argv[]) {
    (void)argc; (void)argv;

    LOGI("=== Physics Demo Starting ===");

    // Initialize SDL
    LOGI("Initializing SDL...");
    if (!SDL_Init(SDL_INIT_EVENTS | SDL_INIT_VIDEO | SDL_INIT_SENSOR)) {
        LOGE("SDL_Init failed (%s)", SDL_GetError());
        return 1;
    }
    LOGI("SDL initialized successfully");

    // Create window and renderer
    LOGI("Creating window and renderer...");
    SDL_Window *win = NULL;
    SDL_Renderer *ren = NULL;
    SDL_CreateWindowAndRenderer("Physics Demo", 800, 600, SDL_WINDOW_RESIZABLE, &win, &ren);
    if (!win || !ren) {
        LOGE("Failed to create window or renderer: %s", SDL_GetError());
        SDL_Quit();
        return 1;
    }
    LOGI("Window and renderer created successfully");

    // Get window size
    int screen_w, screen_h;
    SDL_GetWindowSize(win, &screen_w, &screen_h);

    // Initialize physics balls
    init_balls(screen_w, screen_h);
    LOGI("Initialized %d physics balls", NUM_BALLS);

    // Open sensors
    LOGI("Opening motion sensors...");
    SDL_SensorID *sensors;
    int num_sensors;
    sensors = SDL_GetSensors(&num_sensors);
    LOGI("Found %d sensors", num_sensors);

    if (sensors) {
        for (int i = 0; i < num_sensors; i++) {
            SDL_SensorType type = SDL_GetSensorTypeForID(sensors[i]);
            if (type == SDL_SENSOR_ACCEL) {
                SDL_Sensor *sensor = SDL_OpenSensor(sensors[i]);
                if (sensor) {
                    LOGI("Opened accelerometer sensor");
                } else {
                    LOGE("Failed to open accelerometer sensor");
                }
            } else if (type == SDL_SENSOR_GYRO) {
                SDL_Sensor *sensor = SDL_OpenSensor(sensors[i]);
                if (sensor) {
                    LOGI("Opened gyroscope sensor");
                } else {
                    LOGE("Failed to open gyroscope sensor");
                }
            }
        }
        SDL_free(sensors);
    }

    // Main event loop
    int quit = 0;
    SDL_Event event;
    Uint64 last_time = SDL_GetTicks();

    LOGI("Entering main event loop...");
    while (!quit) {
        Uint64 current_time = SDL_GetTicks();
        float delta_time = (current_time - last_time) / 1000.0f;
        last_time = current_time;

        // Handle events
        while (SDL_PollEvent(&event)) {
            switch (event.type) {
                case SDL_EVENT_QUIT:
                    LOGI("SDL_EVENT_QUIT event received");
                    quit = 1;
                    break;
                case SDL_EVENT_FINGER_DOWN:
                case SDL_EVENT_MOUSE_BUTTON_DOWN:
                    LOGI("Touch/click event received - exiting");
                    quit = 1;
                    break;
                case SDL_EVENT_WINDOW_CLOSE_REQUESTED:
                    LOGI("Window close event received");
                    quit = 1;
                    break;
                case SDL_EVENT_SENSOR_UPDATE:
                    handle_sensor_event(&event.sensor);
                    break;
            }
        }

        // Update physics
        update_physics(screen_w, screen_h, delta_time);

        // Clear screen
        SDL_SetRenderDrawColor(ren, 0, 0, 0, 255);
        SDL_RenderClear(ren);

        // Draw physics balls
        draw_balls(ren);

        // Present the render
        SDL_RenderPresent(ren);

        // Cap frame rate
        SDL_Delay(16); // ~60 FPS
    }

    LOGI("Cleaning up...");
    SDL_DestroyRenderer(ren);
    SDL_DestroyWindow(win);
    SDL_Quit();

    LOGI("=== Physics Demo Exiting ===");
    return 0;
}
