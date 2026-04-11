/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * File Name          : freertos.c
  * Description        : Code for freertos applications
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2026 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */

/* Includes ------------------------------------------------------------------*/
#include "FreeRTOS.h"
#include "task.h"
#include "main.h"
#include "cmsis_os.h"

osThreadId_t ButtonTaskHandle;
const osThreadAttr_t ButtonTask_attributes = {
  .name = "ButtonTask",
  .stack_size = 128 * 4,
  .priority = (osPriority_t) osPriorityNormal,
};
/* Definitions for BlinkTask */
osThreadId_t BlinkTaskHandle;
const osThreadAttr_t BlinkTask_attributes = {
  .name = "BlinkTask",
  .stack_size = 128 * 4,
  .priority = (osPriority_t) osPriorityNormal,
};
/* Definitions for CountQueue */
osMessageQueueId_t CountQueueHandle;
const osMessageQueueAttr_t CountQueue_attributes = {
  .name = "CountQueue"
};
/* Definitions for BinarySem01 */
osSemaphoreId_t BinarySem01Handle;
const osSemaphoreAttr_t BinarySem01_attributes = {
  .name = "BinarySem01"
};


void StartDefaultTask(void *argument);
void StartTask02(void *argument);

void MX_FREERTOS_Init(void);


void MX_FREERTOS_Init(void) {
  BinarySem01Handle = osSemaphoreNew(1, 0, &BinarySem01_attributes);
  CountQueueHandle = osMessageQueueNew (16, sizeof(uint16_t), &CountQueue_attributes);
  ButtonTaskHandle = osThreadNew(StartDefaultTask, NULL, &ButtonTask_attributes);
  BlinkTaskHandle = osThreadNew(StartTask02, NULL, &BlinkTask_attributes);
}

void StartDefaultTask(void *argument)
{
	uint16_t button_count = 0;
	uint32_t start = 0;

	  // Wait for the first button press, to start 4 sec timer
	      if (osSemaphoreAcquire(BinarySem01Handle, osWaitForever) == osOK){
	        button_count = 1;
	        start = osKernelGetTickCount(); // Read start time

	        // while loop that counts button presses for 4 sec
	        while ((osKernelGetTickCount() - start) < 4000){
	          // Calculate the exact time remaining in our 4-second window
	          uint32_t time_remaining = 4000 - (osKernelGetTickCount() - start);

	          // Wait with realising the semaphore, but if button press then count up
	          if (osSemaphoreAcquire(BinarySem01Handle, time_remaining) == osOK){
	        	  button_count++;
	          	  }
	        }
	        // Insert the final count into the queue
	        osMessageQueuePut(CountQueueHandle, &button_count, 0, osWaitForever);
	      }
}

void StartTask02(void *argument)
{
	  uint16_t blinks = 0;

	  for(;;){
		// Wait for the queue to be filled with number of blinks
	    if (osMessageQueueGet(CountQueueHandle, &blinks, NULL, osWaitForever) == osOK){
	      // Blink the LED X times
	      for (uint16_t i = 0; i < blinks; i++){
	        HAL_GPIO_WritePin(LD1_GPIO_Port, LD1_Pin, GPIO_PIN_SET);
	        osDelay(150);
	        HAL_GPIO_WritePin(LD1_GPIO_Port, LD1_Pin, GPIO_PIN_RESET);
	        osDelay(150);
	      }
	    }
	  }
}

