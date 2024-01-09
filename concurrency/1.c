// Importing Libraries
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <unistd.h>
#include <semaphore.h>

// defining macros
#define MAX_COFFEE_TYPES 10
#define MAX_COFFEE_NAME 20
#define MAX_BARISTAS 100
#define MAX_CUSTOMERS 100

// struct definitions
struct coffee_s
{
    char coffee_name[MAX_COFFEE_NAME]; // name of the coffee
    int time_to_make;                  // time to prepare the coffee
};

struct customer_s
{
    int order_id;          // id of the order
    int customer_id;        // id of the customer
    int arrival_time;       // arrival time of the customer. same as when order is placed
    int departure_time;     // departure time of the customer
    int tolerance_time;     // tolerance time of the customer
    struct coffee_s coffee; // coffee ordered by the customer
};

struct orders_s
{
    int order_id;               // id of the order
    int barista_id;             // id of the barista who is preparing the order. if no barista assigned yet, then barista_id is -1
    struct customer_s customer; // customer who placed the order
    int is_taken_up;            // time when the order is started
    int is_completed;           // 1 if order is completed, 0 otherwise . Depends on barista. If barista is done with order then is_completed = 1
    int is_customer_present;    // 1 if customer is present, 0 otherwise. If customer is present then is_customer_present = 1
    int is_given_to_customer;   // 1 if order is given to customer, 0 otherwise. If order received by customer then is_given_to_customer = 1
    int is_to_be_considered;    // 1 if order is to be considered, 0 otherwise. Act as flag for if order is to be considered or not. Similar to popping out of a queu
    int order_printed;          // 1 if order is printed, 0 otherwise. If order is printed then order_printed = 1
};

struct barista_s
{
    int barista_id;         // id of the barista
    int coffee_wasted;      // number of coffee prepared that goes wasted
    int is_free;            // 1 if barista is free, 0 otherwise
    struct orders_s *order; // order that the barista is preparing. if no orrder, then order is NULL
};

// global variables
int B, K, N;                                    // B = number of baristas, K = number of coffee types, N = number of customers
int ticks = 0;                                  // global time variable
int is_to_be_considered_counter = 0;            // counter for is_to_be_considered flag. When this is equal to orders, then all orders have been considered
int thread_closed = 0;                          // flag to check if all threads have been closed
int coffee_Wasted_counter = 0;
struct coffee_s coffee_types[MAX_COFFEE_TYPES]; // array of coffee types
struct customer_s customers[MAX_CUSTOMERS];     // array of customers
struct orders_s orders[MAX_CUSTOMERS];          // array of orders
struct barista_s baristas[MAX_BARISTAS];        // array of baristas

// array of semaphores
sem_t sem_lock;                     // semaphore for lock
sem_t sem_baristas[MAX_BARISTAS];   // semaphores for baristas
sem_t sem_customers[MAX_CUSTOMERS]; // semaphores for customers

void *barista_func(void *arg)
{
    struct barista_s *barista = (struct barista_s *)arg;
    while (1)
    {
        if (is_to_be_considered_counter == N)
        {
            break;
        }


        int temp_id = barista->barista_id;
        if (temp_id == 0)
        {
            sem_wait(&sem_customers[N - 1]);
        }
        else
        {
            sem_wait(&sem_baristas[temp_id - 1]);
        }

        sem_wait(&sem_lock);

        if (barista->is_free == 1)
        {
            for (int i = 0; i < N; i++)
            {
                if (orders[i].is_to_be_considered == 1 && orders[i].barista_id == -1 && ticks >= orders[i].customer.arrival_time+1)
                {
                    orders[i].barista_id = temp_id;
                    orders[i].is_taken_up = ticks;
                    barista->order = &orders[i];
                    barista->is_free = 0;

                    // printing in cyan
                    printf("\033[1;36m");
                    printf("Barista %d starts preparing order of customer %d at time %d\n", temp_id+1, orders[i].customer.customer_id+1, ticks);
                    printf("\033[0m");
                    break;
                }
            }
        }
        else if (barista->is_free == 0)
        {
            // check if order is completed 
            if ( barista->order->is_completed == 1)
            {
                barista->is_free = 1;
                barista->order = NULL;
            }
            else
            {
                // check if order is to be given to customer
                if (ticks - barista->order->is_taken_up == barista->order->customer.coffee.time_to_make)
                {
                    barista->is_free = 1;
                    barista->order->is_completed = 1;
                    // printing in blue
                    printf("\033[1;34m");
                    printf("Barista %d finishes preparing order of customer %d at time %d\n", temp_id+1, barista->order->customer.customer_id+1, ticks);
                    printf("\033[0m");
                    if (barista->order->is_customer_present == 1)
                    {
                        barista->order->is_given_to_customer = 1;
                        barista->order->is_customer_present = 0;

                        // printf("Customer %d leaves with order at time %d \n", barista->order->customer.customer_id+1, ticks);
                    }
                    else
                    {
                        barista->coffee_wasted++;
                    }
                    barista->order->is_to_be_considered = 0;
                    is_to_be_considered_counter++;
                    barista->order = NULL;

                }
            }
        }

        sem_post(&sem_lock);

        sem_post(&sem_baristas[temp_id]);
    }
    thread_closed++;
    pthread_exit(NULL);
}

void *customer_func(void *arg)
{
    struct customer_s *customer = (struct customer_s *)arg;

    while(1)
    {
        if (is_to_be_considered_counter == N)
        {
            break;
        }

        int temp_id = customer->customer_id;
        if (temp_id == 0)
        {
            sem_wait(&sem_baristas[B - 1]);
        }
        else
        {
            sem_wait(&sem_customers[temp_id - 1]);
        }
        sem_wait(&sem_lock);

        int order_id = customer->order_id;

        if (ticks == customer->arrival_time)
        {
            printf("Customer %d arrives at %d.\n", temp_id+1, ticks);
            // print in yellow color
            printf("\033[1;33m");
            printf("Customer %d orders %s.\n", temp_id+1, customer->coffee.coffee_name);
            printf("\033[0m");
        }

        if (ticks == customer->arrival_time + customer->tolerance_time+1)
        {
            orders[order_id].is_customer_present = 0;
        
            if (orders[order_id].is_completed == 0)
            {
                // printing in red
                printf("\033[1;31m");
                printf("Customer %d leaves without being served at %d.\n", temp_id+1, ticks);
                printf("\033[0m");
                orders[order_id].customer.departure_time = ticks;
                if (orders[order_id].barista_id == -1)
                {
                    orders[order_id].is_to_be_considered = 0;
                    is_to_be_considered_counter++;
                }

            }
        }

        if (orders[order_id].is_given_to_customer == 1 && orders[order_id].order_printed == 0)
        {
            // printing in green
            printf("\033[1;32m");
            printf("Customer %d receives order at %d.\n", temp_id+1, orders[order_id].is_taken_up + orders[order_id].customer.coffee.time_to_make);
            printf("\033[0m");
            orders[order_id].customer.departure_time = orders[order_id].is_taken_up + orders[order_id].customer.coffee.time_to_make;
            orders[order_id].order_printed = 1;
        }

        if (temp_id == 0)
        {
            ticks++;
            sleep(1); // comment this to not simulate in real time
        }

        sem_post(&sem_lock);
        sem_post(&sem_customers[temp_id]);


    }

    thread_closed++;
    pthread_exit(NULL);
}

int main()
{
    scanf("%d %d %d", &B, &K, &N); // taking input from the user

    // taking the input of coffee
    for (int i = 0; i < K; i++)
    {
        scanf("%s %d", coffee_types[i].coffee_name, &coffee_types[i].time_to_make);
    }

    // taking the input of customers. we assume that the order of input is sequential
    for (int i = 0; i < N; i++)
    {
        int temp;
        scanf("%d %s %d %d", &temp, customers[i].coffee.coffee_name, &customers[i].arrival_time, &customers[i].tolerance_time);
        for (int j = 0; j < K; j++)
        {
            if (strcmp(customers[i].coffee.coffee_name, coffee_types[j].coffee_name) == 0)
            {
                customers[i].coffee.time_to_make = coffee_types[j].time_to_make;
                break;
            }
        }
        customers[i].order_id = i;
        customers[i].customer_id = i; // customer id + 1 = actual input id.  Considering that given in sequential order.
        customers[i].departure_time = customers[i].arrival_time + customers[i].tolerance_time;
        orders[i].order_id = i;       
        orders[i].customer = customers[i];
        orders[i].barista_id = -1;          // not yet assigned
        orders[i].is_taken_up = -1;          // not yet taken up
        orders[i].is_completed = 0;         // not yet completed
        orders[i].is_given_to_customer = 0; // not yet given to customer
        orders[i].is_customer_present = 1;  // customer is present
        orders[i].is_to_be_considered = 1;  // to be considered
        orders[i].order_printed = 0;        // not yet printed
    }

    // initializing semaphores
    sem_init(&sem_lock, 0, 1);

    for (int i = 0; i < B; i++)
    {
        sem_init(&sem_baristas[i], 0, 0);
    }

    for (int i = 0; i < N; i++)
    {
        sem_init(&sem_customers[i], 0, 0);
    }

    // creating threads
    pthread_t barista_threads[B];
    pthread_t customer_threads[N];

    // creating barista threads
    for (int i = 0; i < B; i++)
    {
        baristas[i].barista_id = i;
        baristas[i].coffee_wasted = 0;
        baristas[i].is_free = 1;
        baristas[i].order = malloc(sizeof(struct orders_s));
        pthread_create(&barista_threads[i], NULL, barista_func, (void *)&baristas[i]);
    }

    // creating customer threads
    for (int i = 0; i < N; i++)
    {
        pthread_create(&customer_threads[i], NULL, customer_func, (void *)&customers[i]);
    }

    printf("\nSimulation Begins\n");
    sem_post(&sem_customers[0]);

    while (1)
    {
        if (thread_closed == B + N && is_to_be_considered_counter == N)
        {
            printf("Simulation Over\n");
            break;
        }
    }

    int coffee_wasted = 0;

    for (int i=0; i<B; i++)
    {
        coffee_wasted += baristas[i].coffee_wasted;
    }


    int sum_time_wait = 0;

    for (int i=0; i<N; i++)
    {
        // this assumes that if customer leaves midway during prepartion, then wait time is tolerance time
        // if (orders[i].is_given_to_customer == 1)
        // {
        //     sum_time_wait += orders[i].customer.departure_time - orders[i].customer.arrival_time - orders[i].customer.coffee.time_to_make;
        // }
        // else
        // {
        //     sum_time_wait += orders[i].customer.departure_time - orders[i].customer.arrival_time;
        // }

        if (orders[i].is_taken_up != -1)
        {
            sum_time_wait += orders[i].is_taken_up - orders[i].customer.arrival_time;
        }
        else
        {
            sum_time_wait += orders[i].customer.departure_time - orders[i].customer.arrival_time;
        
        }
    }

    printf("Coffees wasted are %d\n", coffee_wasted);
    printf("Average waiting time is %f\n", (float)sum_time_wait/N);

    return 0;
}