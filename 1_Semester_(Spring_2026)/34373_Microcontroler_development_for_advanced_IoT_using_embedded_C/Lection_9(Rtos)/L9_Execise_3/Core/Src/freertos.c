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
#include "usart.h"
#include <string.h>
#include <stdio.h>

osThreadId_t Task1Handle;
const osThreadAttr_t Task1_attributes = {
  .name = "Task1",
  .stack_size = 128 * 4,
  .priority = (osPriority_t) osPriorityNormal,
};
/* Definitions for Task2 */
osThreadId_t Task2Handle;
const osThreadAttr_t Task2_attributes = {
  .name = "Task2",
  .stack_size = 128 * 4,
  .priority = (osPriority_t) osPriorityHigh,
};

void StartDefaultTask(void *argument);
void StartTask02(void *argument);

void MX_FREERTOS_Init(void);

void MX_FREERTOS_Init(void) {
  Task1Handle = osThreadNew(StartDefaultTask, NULL, &Task1_attributes);
  Task2Handle = osThreadNew(StartTask02, NULL, &Task2_attributes);
}

void StartDefaultTask(void *argument)
{
	char *msg1 = "Task 1\r\n";
	  /* Infinite loop */
	  for(;;)
	  {
	    HAL_UART_Transmit(&huart2, (uint8_t*)msg1, strlen(msg1), HAL_MAX_DELAY);
	    osDelay(1000); // wait for 1 sec
	  }
}

void StartTask02(void *argument)
{
	char *msg2 = "Task 2\r\n";
	  for(;;)
	  {
	    HAL_UART_Transmit(&huart2, (uint8_t*)msg2, strlen(msg2), HAL_MAX_DELAY);
	    osDelay(500); // wait for 0.5 sec
	  }
}

/* Private application code --------------------------------------------------*/
/* USER CODE BEGIN Application */

/* USER CODE END Application */

