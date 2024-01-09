// importing libraries
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <string.h>
#include <semaphore.h>

#define ANSI_COLOR_ORANGE "\x1b[38;5;208m"
#define ANSI_COLOR_YELLOW "\x1b[33m"
#define ANSI_COLOR_RESET "\x1b[0m"

// defining constants
#define MAX_ICECREAM_MACHINES 10
#define MAX_CUSTOMERS_LIMIT_TOTAL 15
#define MAX_CUSTOMERS_LIMIT_ATONCE 10 // K in the question
#define MAX_ICECREAM_FLAVOURS 10
#define MAX_ICECREAM_FLAVOURS_NAME 20
#define MAX_ICECREAM_TOPPINGS 10
#define MAX_ICECREAM_TOPPINGS_NAME 20
#define MAX_TOTAL_ORDERS 100
#define MAX_ICECREAM_PER_CUSTOMER 10
#define TOKENS 10

// struct definitions

struct icecream_flavour
{
    char name[MAX_ICECREAM_FLAVOURS_NAME];
    int time_to_prepare;
    int flavour_id;
};

struct toppings
{
    char name[MAX_ICECREAM_TOPPINGS_NAME];
    int quantity;
    int topping_id;
};

struct icecream
{
    int is_possible_to_make;
    int icecream_machine_preparing_id;
    int toppings_num;
    struct icecream_flavour flavour;
    struct toppings topping[MAX_ICECREAM_TOPPINGS];
};

struct customer
{
    int customer_id;
    int arrival_time;
    int leaving_time;
    int number_of_icecreams;
    int leaves; // 0 if hasnt left, 1 if left
    struct icecream icecreams[MAX_ICECREAM_PER_CUSTOMER];
    int order_id_s[MAX_ICECREAM_PER_CUSTOMER];
    int leaves_with_order;
    int leaves_without_order_due_to_is_atplacement;   // ingredient shortage at placement
    int leaves_without_order_due_to_is_atpreparation; // ingredient shortage at preparation
    int leaves_due_to_no_machines;                    // unserviced
    int leaves_due_to_no_seats;
};

struct order // specific for the ice cream being made
{
    int is_to_considered;
    int is_placed;                        // has order been placed or not. initially -1 t show not placed. rest is ticks time
    int is_completed;                     // has order been completed or not. initially 0 to show not completed
    int rejected;                         // gets rejected
    int rejected_due_to_is_atplacement;   // is order rejected or not. initially 0 to show not rejected
    int rejected_due_to_is_atpreparation; // is order rejected or not. initially 0 to show not rejected
    int rejected_due_to_no_machines;      // is order rejected or not. initially 0 to show not rejected. Increment whenever a particular machine cannot service them
    int rejected_due_to_no_seats;         // is order rejected or not. initially 0 to show not rejected
    int order_id;                         // order id
    int customer_id;                      // customer id
    int customer_order_id;                // order id of the customer
    int icecream_machine_id;              // ice cream machine id
    int start_time_of_order;              // start time of order
    struct icecream icecreams;
};

struct icecream_machine
{
    int icecream_machine_id;
    int start_time;
    int end_time;
    int is_busy;         // 1 if busy preparing order otherwise 0
    struct order *order; // NULL if no order is assigned
};

int N, K, F, T;
int ticks = 0;
int total_customers = 0;
int total_orders = 0;
int orders_considered = 0;
int machines_stopped_working = 0;
int customers_sitting_in_parlour = 0;
int threads_closed = 0;
int super = 0;
struct icecream_flavour icecream_flavours[MAX_ICECREAM_FLAVOURS];
struct toppings toppings[MAX_ICECREAM_TOPPINGS];
struct icecream icecreams[MAX_TOTAL_ORDERS];
struct order orders[MAX_TOTAL_ORDERS];
struct icecream_machine icecream_machines[MAX_ICECREAM_MACHINES];
struct customer customers[MAX_CUSTOMERS_LIMIT_TOTAL];
int machine_reject_which_order[MAX_ICECREAM_MACHINES][MAX_TOTAL_ORDERS];

sem_t mutex;
sem_t ice_cream_machine_condition[MAX_ICECREAM_MACHINES];
sem_t customer_condition[MAX_CUSTOMERS_LIMIT_TOTAL];

void *icecream_machine_func(void *arg)
{
    struct icecream_machine *icecream_machine = (struct icecream_machine *)arg;
    while (1)
    {
        if (orders_considered == total_orders && machines_stopped_working == N || super == 1)
        {
            break;
        }

        int icecream_machine_id = icecream_machine->icecream_machine_id;
        int t_id = icecream_machine_id - 1;
        if (t_id == 0)
        {
            sem_wait(&customer_condition[total_customers - 1]);
        }
        else
        {
            sem_wait(&ice_cream_machine_condition[t_id - 1]);
        }
        sem_wait(&mutex);

        // actual logic
        if (icecream_machine->start_time == ticks)
        {
            // print in orange color
            // printf("Icecream Machine %d started at %d seconds\n", icecream_machine->icecream_machine_id, icecream_machine->start_time);
            printf(ANSI_COLOR_ORANGE "Icecream Machine %d started at %d seconds\n" ANSI_COLOR_RESET, icecream_machine->icecream_machine_id, icecream_machine->start_time);
        }

        if (icecream_machine->start_time <= ticks && icecream_machine->end_time > ticks)
        {
            if (icecream_machine->is_busy != 1)
            {
                // check for orders
                for (int i = 0; i < total_orders; i++)
                {
                    if (orders[i].is_to_considered == 1 && orders[i].icecream_machine_id == -1 && orders[i].is_placed != -1)
                    {
                        int time_place_order = orders[i].is_placed;
                        int time_to_finish = 0;
                        int start_time = 0;
                        if (time_place_order < icecream_machine->start_time)
                        {
                            start_time = ticks;
                            time_to_finish = start_time + orders[i].icecreams.flavour.time_to_prepare;
                        }
                        else
                        {
                            start_time = ticks;
                            time_to_finish = start_time + orders[i].icecreams.flavour.time_to_prepare;
                        }

                        if (time_to_finish >= icecream_machine->end_time)
                        {
                            if (machine_reject_which_order[icecream_machine_id - 1][i] == 0)
                            {
                                machine_reject_which_order[icecream_machine_id - 1][i] = 1;
                                orders[i].rejected_due_to_no_machines += 1;
                                // orders[i].rejected = 1;
                            }
                            if ((orders[i].rejected_due_to_no_machines) == N)
                            {
                                orders[i].rejected = 1;
                                orders_considered++;
                                orders[i].is_to_considered = 0;
                            }
                        }
                        else if (time_to_finish <= icecream_machine->end_time)
                        {
                            // check for ingredients
                            int is_possible_to_make = 1;
                            int temp_toppings[T];
                            memset(temp_toppings, 0, sizeof(temp_toppings));

                            for (int j = 0; j < T; j++)
                            {
                                if(j<orders[i].icecreams.toppings_num)
                                {
                                temp_toppings[orders[i].icecreams.topping[j].topping_id - 1] += 1;
                                }

                            }


                            for (int i = 0; i < T; i++)
                            {
                                if (toppings[i].quantity != -1)
                                {
                                    if (toppings[i].quantity < temp_toppings[i])
                                    {
                                        is_possible_to_make = 0;
                                        break;
                                    }
                                }

                            }

                            if (is_possible_to_make == 0)
                            {
                                if (machine_reject_which_order[icecream_machine_id][i] == 0)
                                {
                                    machine_reject_which_order[icecream_machine_id][i] = 1;
                                    orders[i].rejected_due_to_is_atpreparation = 1;
                                    orders[i].rejected = 1;
                                    orders[i].is_to_considered = 0;
                                    orders_considered++;
                                    printf("Order %d rejected due to ingredient shortage at preparation at %d\n", orders[i].order_id, ticks);
                                }
                            }
                            else
                            {
                                // print in cyan
                                printf("\033[1;36m");
                                printf("Machine %d started preparing order %d of customer %d at %d\n", icecream_machine->icecream_machine_id, orders[i].customer_order_id, orders[i].customer_id, start_time);
                                printf("\033[0m");
                                orders[i].icecream_machine_id = icecream_machine_id;
                                orders[i].start_time_of_order = start_time;
                                icecream_machine->is_busy = 1;
                                icecream_machine->order = &orders[i];

                                //  decrementing toppings
                                for (int j = 0; j < orders[i].icecreams.toppings_num; j++)
                                {
                                    if (toppings[orders[i].icecreams.topping[j].topping_id - 1].quantity != -1)
                                    {
                                        toppings[orders[i].icecreams.topping[j].topping_id - 1].quantity -= 1;
                                    }
                                }

                                break;
                            }
                        }
                    }
                }
            }
            else if (icecream_machine->is_busy == 1)
            {
                // check if assigned order is complete or not
                int order_id = icecream_machine->order->order_id;
                int start_time = icecream_machine->order->start_time_of_order;
                int time_to_finish = start_time + icecream_machine->order->icecreams.flavour.time_to_prepare;

                if (time_to_finish == ticks)
                {
                    // print in blue
                    printf("\033[1;34m");
                    printf("Machine %d finished preparing order %d of customer %d at %d\n", icecream_machine->icecream_machine_id, icecream_machine->order->customer_order_id, icecream_machine->order->customer_id, ticks);
                    printf("\033[0m");
                    icecream_machine->is_busy = 0;
                    icecream_machine->order->is_completed = 1;
                    icecream_machine->order->is_to_considered = 0;
                    orders_considered++;
                    icecream_machine->order = NULL;
                }
            }
        }

        if (icecream_machine->end_time == ticks)
        {
            // print in orange color
            printf(ANSI_COLOR_ORANGE "Icecream Machine %d stopped at %d seconds\n" ANSI_COLOR_RESET, icecream_machine->icecream_machine_id, icecream_machine->end_time);
            machines_stopped_working++;
        }

        ///////////////////////////////////////////////////////
        sem_post(&mutex);
        sem_post(&ice_cream_machine_condition[t_id]);
    }

    threads_closed++;
    pthread_exit(NULL);
}

void *customer_func(void *arg)
{
    struct customer *customer = (struct customer *)arg;
    while (1)
    {
        // printf("ticks: %d\n", ticks);
        if (orders_considered == total_orders && machines_stopped_working == N || super == 1)
        {
            break;
        }

        int customer_id = customer->customer_id;
        int c_id = customer_id - 1;
        if (c_id == 0)
        {
            sem_wait(&ice_cream_machine_condition[N - 1]);
        }
        else
        {
            sem_wait(&customer_condition[c_id - 1]);
        }

        sem_wait(&mutex);

        // actual logic

        if (customer->arrival_time == ticks)
        {
            printf("Customer %d arrived at %d seconds\n", customer->customer_id, customer->arrival_time);

            if (customers_sitting_in_parlour == K)
            {
                // print in red
                printf("\033[1;31m");
                printf("Customer %d left due to no seats available\n", customer->customer_id);
                printf("\033[0m");
                customer->leaving_time = ticks;
                customer->leaves_due_to_no_seats = 1;
                customer->leaves = 1;
                for (int i = 0; i < customer->number_of_icecreams; i++)
                {
                    orders[customer->order_id_s[i] - 1].rejected_due_to_no_seats = 1;
                    orders[customer->order_id_s[i] - 1].rejected = 1;
                    orders[customer->order_id_s[i] - 1].is_to_considered = 0;
                    orders_considered++;
                }
            }
            else
            {
                customers_sitting_in_parlour++;
                printf("Customer %d orders %d icecreams\n", customer->customer_id, customer->number_of_icecreams);
                for (int i = 0; i < customer->number_of_icecreams; i++)
                {
                    printf(ANSI_COLOR_YELLOW "Icecream Order %d: %s  " ANSI_COLOR_RESET, i + 1, customer->icecreams[i].flavour.name);
                    for (int j = 0; j < customer->icecreams[i].toppings_num; j++)
                    {
                        printf(ANSI_COLOR_YELLOW "%s " ANSI_COLOR_RESET, customer->icecreams[i].topping[j].name);
                    }
                    printf("\n");
                }

                // checks for each icecream if it is possible to make or not
                int temp_toppings[T];
                memset(temp_toppings, 0, sizeof(temp_toppings));

                for (int i = 0; i < customer->number_of_icecreams; i++)
                {
                    struct icecream icecream = customer->icecreams[i];
                    for (int j = 0; j < icecream.toppings_num; j++)
                    {
                        temp_toppings[icecream.topping[j].topping_id - 1] += 1;
                    }
                }

                int is_possible_to_make = 1;

                for (int i = 0; i < T; i++)
                {
                    if (toppings[i].quantity != -1)
                    {
                        if (toppings[i].quantity < temp_toppings[i])
                        {
                            is_possible_to_make = 0;
                            break;
                        }
                    }
                }

                if (is_possible_to_make == 0)
                {
                    // print in red
                    printf("\033[1;31m");
                    printf("Customer %d left due to ingredient shortage at placement of order at %d\n", customer->customer_id, ticks);
                    printf("\033[0m");
                    customer->leaving_time = ticks;
                    customer->leaves_without_order_due_to_is_atplacement = 1;
                    customer->leaves = 1;
                    customers_sitting_in_parlour--;
                    for (int i = 0; i < customer->number_of_icecreams; i++)
                    {
                        orders[customer->order_id_s[i] - 1].rejected_due_to_is_atplacement = 1;
                        orders[customer->order_id_s[i] - 1].rejected = 1;
                        orders[customer->order_id_s[i] - 1].is_to_considered = 0;
                        orders_considered++;
                    }
                }
                else
                {
                    for (int i = 0; i < customer->number_of_icecreams; i++)
                    {
                        orders[customer->order_id_s[i] - 1].is_to_considered = 1;
                        orders[customer->order_id_s[i] - 1].is_placed = ticks;
                    }
                }
            }
        }

        if (customer->arrival_time < ticks && customer->leaves != 1)
        {
            // check all orders of the customer.
            // in case some order has been rejected, then reject all orders of the customer and customer leaves
            int is_all_orders_rejected = 1;
            int no_service = 0;
            int ingredient_shortage = 0;
            for (int i = 0; i < customer->number_of_icecreams; i++)
            {
                if (orders[customer->order_id_s[i] - 1].rejected_due_to_is_atpreparation == 1) // even if  one is rejected, customer leaves
                {
                    is_all_orders_rejected = 0;

                    ingredient_shortage = 1;
                }
                if (orders[customer->order_id_s[i] - 1].rejected_due_to_no_machines == N)
                {
                    is_all_orders_rejected = 0;
                    no_service = 1;
                }
            }

            if (is_all_orders_rejected == 0)
            {
                for (int i = 0; i < customer->number_of_icecreams; i++)
                {
                    orders[customer->order_id_s[i] - 1].rejected = 1;
                    orders[customer->order_id_s[i] - 1].is_to_considered = 0;
                    if (no_service == 1)
                    {
                        orders[customer->order_id_s[i] - 1].rejected_due_to_no_machines = N;
                    }
                    else if (ingredient_shortage == 1)
                    {
                        orders[customer->order_id_s[i] - 1].rejected_due_to_is_atpreparation = 1;
                    }
                }
                customer->leaves = 1;
                customer->leaving_time = ticks;
                customers_sitting_in_parlour--;
                if (no_service)
                {
                    customer->leaves_due_to_no_machines = 1;
                }
                if (ingredient_shortage)
                {

                    customer->leaves_without_order_due_to_is_atpreparation = 1;
                }

                if (no_service == 1)
                {
                    // print in red
                    printf("\033[1;31m");
                    printf("Customer %d left due to no machines available at %d\n", customer->customer_id, ticks);
                    printf("\033[0m");
                }
                else if (ingredient_shortage == 1)
                {
                    // print in red
                    printf("\033[1;31m");
                    printf("Customer %d left due to ingredient shortage at preparation of order at %d\n", customer->customer_id, ticks);
                    printf("\033[0m");
                }
            }
        }

        int are_all_orders_completed = 0;
        for (int i = 0; i < customer->number_of_icecreams; i++)
        {
            if (orders[customer->order_id_s[i] - 1].is_completed == 0)
            {
                are_all_orders_completed = 0;
                break;
            }
            else if (orders[customer->order_id_s[i] - 1].is_completed == 1)
            {
                are_all_orders_completed = 1;
            }
        }

        if (are_all_orders_completed == 1)
        {
            if (customer->leaves == 0)
            {
                // print in green
                printf("\033[1;32m");
                printf("Customer %d left with fulfilled order at %d\n", customer->customer_id, ticks);
                printf("\033[0m");

                customer->leaves = 1;
                customer->leaves_with_order = 1;
                customer->leaving_time = ticks;
                customers_sitting_in_parlour--;
            }
        }

        /////////////////////////////////////////////////////
        if (c_id == 0)
        {
            ticks++;
            // sleep(1);

            // checking if all limited ingredients are not 0
            int is_all_ingredients_zero = 1;
            for (int i = 0; i < T; i++)
            {
                if (toppings[i].quantity != -1)
                {
                    if (toppings[i].quantity != 0)
                    {
                        is_all_ingredients_zero = 0;
                        break;
                    }
                }
            }

            if (is_all_ingredients_zero == 1)
            {
                super = 1;
            }
        }
        sem_post(&mutex);
        sem_post(&customer_condition[c_id]);
    }
    threads_closed++;
    pthread_exit(NULL);
}

int main()
{
    // input for N, K, F, T
    scanf("%d %d %d %d", &N, &K, &F, &T); // N = number of ice cream machines, K = maximum seating capacity, F = number of flavours, T = number of toppings

    // input for ice cream machines
    for (int i = 0; i < N; i++)
    {
        scanf("%d %d", &icecream_machines[i].start_time, &icecream_machines[i].end_time);
        icecream_machines[i].icecream_machine_id = i + 1;
        icecream_machines[i].is_busy = 0;
        icecream_machines[i].order = malloc(sizeof(struct order));
    }

    // input for ice cream flavours
    for (int i = 0; i < F; i++)
    {
        scanf("%s %d", icecream_flavours[i].name, &icecream_flavours[i].time_to_prepare);
    }

    // input for toppings
    for (int i = 0; i < T; i++)
    {
        scanf("%s %d", toppings[i].name, &toppings[i].quantity);
        toppings[i].topping_id = i + 1;
    }

    int customers_index = 0;
    int customer_id, arrival_time, number_of_icecreams;
    int orders_index = 0;
    while (1)
    {
        customer_id = -1;
        arrival_time = -1;
        number_of_icecreams = -1;

        scanf("%d", &customer_id);
        if (customer_id == -1)
        {
            break;
        }
        scanf("%d", &arrival_time);
        if (arrival_time == -1)
        {
            break;
        }
        scanf("%d", &number_of_icecreams);
        if (number_of_icecreams == -1)
        {
            break;
        }

        struct icecream icecreams[number_of_icecreams];
        for (int i = 0; i < number_of_icecreams; i++)
        {
            char temp[100];

            // read input from stdin in while loop character wise
            char c;
            int index = 0;
            if (i == 0)
            {

                c = getchar();
            }
            while (EOF != (c = getchar()) && c != '\n')
            {
                temp[index] = c;
                index++;
            }
            temp[index] = '\0';

            // tokeinze the string on basis of space and store first in ice cream flavour and rest in toppings

            char *token = strtok(temp, " \n\t\r");
            char *token_list[TOKENS];
            int token_list_ptr = 0;
            while (token != NULL)
            {
                // adding tokens to a list
                token_list[token_list_ptr] = token;
                token_list_ptr++;
                token = strtok(NULL, " \n\t\r");
            }

            int flavour_id = -1;

            for (int i = 0; i < F; i++)
            {
                if (strcmp(token_list[0], icecream_flavours[i].name) == 0)
                {
                    flavour_id = i;
                    break;
                }
            }

            int topping_id[token_list_ptr - 1];

            for (int i = 1; i < token_list_ptr; i++)
            {
                for (int j = 0; j < T; j++)
                {
                    if (strcmp(token_list[i], toppings[j].name) == 0)
                    {
                        topping_id[i - 1] = j;
                        break;
                    }
                }
            }

            // sort the array topping id
            for (int i = 0; i < token_list_ptr - 1; i++)
            {
                for (int j = i + 1; j < token_list_ptr - 1; j++)
                {
                    if (topping_id[i] > topping_id[j])
                    {
                        int temp1 = topping_id[i];
                        topping_id[i] = topping_id[j];
                        topping_id[j] = temp1;
                    }
                }
            }

            struct icecream icecream;
            icecream.flavour = icecream_flavours[flavour_id];
            icecream.toppings_num = token_list_ptr - 1;
            for (int j = 0; j < token_list_ptr - 1; j++)
            {
                icecream.topping[j] = toppings[topping_id[j]];
            }
            icecream.icecream_machine_preparing_id = -1;
            icecream.is_possible_to_make = 0;
            icecreams[i] = icecream;
        }
        struct customer customer;
        customer.customer_id = customer_id; // we will assume that customers arrive sequentially
        customer.arrival_time = arrival_time;
        customer.leaving_time = -1;
        customer.number_of_icecreams = number_of_icecreams;
        customer.leaves_with_order = 0;
        customer.leaves_without_order_due_to_is_atplacement = 0;
        customer.leaves_without_order_due_to_is_atpreparation = 0;
        customer.leaves_due_to_no_machines = 0;
        customer.leaves_due_to_no_seats = 0;
        customer.leaves = 0;
        for (int i = 0; i < number_of_icecreams; i++)
        {
            customer.icecreams[i] = icecreams[i];

            orders[orders_index].is_to_considered = 1;
            orders[orders_index].icecreams = icecreams[i];
            orders[orders_index].customer_id = customer_id;
            orders[orders_index].order_id = orders_index + 1;
            orders[orders_index].start_time_of_order = -1;
            orders[orders_index].icecream_machine_id = -1;
            orders[orders_index].customer_order_id = i + 1;
            orders[orders_index].is_placed = -1;
            orders[orders_index].rejected_due_to_is_atplacement = 0;
            orders[orders_index].rejected_due_to_is_atpreparation = 0;
            orders[orders_index].rejected_due_to_no_machines = 0;
            orders[orders_index].rejected_due_to_no_seats = 0;
            orders[orders_index].is_completed = 0;
            orders[orders_index].rejected = 0;
            customer.order_id_s[i] = orders_index + 1;
            orders_index++;
        }
        customers[customers_index] = customer;
        customers_index++;
    }

    total_customers = customers_index;
    total_orders = orders_index;

    // initialize semaphores
    sem_init(&mutex, 0, 1);
    for (int i = 0; i < N; i++)
    {
        sem_init(&ice_cream_machine_condition[i], 0, 0);
    }
    for (int i = 0; i < total_customers; i++)
    {
        sem_init(&customer_condition[i], 0, 0);
    }

    // creting threads
    pthread_t icecream_machine_threads[N];
    pthread_t customer_threads[total_customers];

    for (int i = 0; i < N; i++)
    {
        for (int j = 0; j < total_orders; j++)
        {
            machine_reject_which_order[i][j] = 0;
        }
    }

    for (int i = 0; i < N; i++)
    {
        pthread_create(&icecream_machine_threads[i], NULL, icecream_machine_func, (void *)&icecream_machines[i]);
    }

    for (int i = 0; i < total_customers; i++)
    {
        pthread_create(&customer_threads[i], NULL, customer_func, (void *)&customers[i]);
    }

    printf("Parlour Opened\n");
    sem_post(&customer_condition[0]);

    while (1)
    {
        if (threads_closed == N + total_customers && orders_considered == total_orders)
        {
            printf("Parlour Closed\n");
            break;
        }
        if (super == 1)
        {
            printf("Parlour Closed due to Ingredient Depletion\n");
            break;
        }
    }

    return 0;
}