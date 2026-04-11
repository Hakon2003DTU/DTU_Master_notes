/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
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
#include "main.h"
#include "tim.h"
#include "gpio.h"

void SystemClock_Config(void);


int main(void)
{

  HAL_Init();
  SystemClock_Config();
  MX_GPIO_Init();
  MX_TIM2_Init();
  HAL_TIM_PWM_Start(&htim2, TIM_CHANNEL_1);
  MX_TIM17_Init();
  HAL_TIM_PWM_Start(&htim17, TIM_CHANNEL_1);
  MX_TIM1_Init();
  HAL_TIM_PWM_Start(&htim1, TIM_CHANNEL_4);

  uint32_t Duty_Max = 1000; // Max puls value

  while (1)
  {

	  // Get the time variable that shows the 5 sec from 0-5000
	  uint32_t time = HAL_GetTick() % 5000;

	  // Get the current color state from time
	  uint32_t state = time / 833;

	  //  Get the color state time (shows how much time has gone in the state)
	  uint32_t state_time = time % 833;

	  // Calculating the increase and decrease of pwm
	  uint32_t pwm_val = (state_time * Duty_Max) / 833;
	  uint32_t Decrease_PWM =  Duty_Max - pwm_val;

	  // Mixing the colors
	  uint32_t red = 0, green = 0, blue = 0;

	  switch(state){
	  	  case 0: // Red to Yellow
	  		  red = Duty_Max;
	  		  green = pwm_val;
	  		  blue = 0;
	  		  break;
	  	  case 1:// Yellow to Green
	  		  red = Decrease_PWM;
	  		  green = Duty_Max;
	  		  blue = 0;
	  		  break;
	  	  case 2:// Green to Cyan
	  		  red = 0;
	  		  green = Duty_Max;
	  		  blue = pwm_val;
	  		  break;
	  	  case 3: // Cyan to Blue
	  		  red = 0;
	  		  green = Decrease_PWM;
	  		  blue = Duty_Max;
	  		  break;
	  	  case 4: // Blue to Magenta
	  		  red = pwm_val;
	  		  green = 0;
	  		  blue = Duty_Max;
	  		  break;
	  	  case 5: // Magenta to Red
	  		  red = Duty_Max;
	  		  green = 0;
	  		  blue = Decrease_PWM;
	  		  break;
	  }
	  // TIM2 Channel 1 (Pin PA0)
	  __HAL_TIM_SET_COMPARE(&htim2, TIM_CHANNEL_1, red);

	  // TIM1 Channel 4 (Pin PC3)
	  __HAL_TIM_SET_COMPARE(&htim1, TIM_CHANNEL_4, green);

	  // TIM17 Channel 1 (Pin PA7)
	  __HAL_TIM_SET_COMPARE(&htim17, TIM_CHANNEL_1, blue);


  }

}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};
  RCC_PeriphCLKInitTypeDef PeriphClkInit = {0};

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSI;
  RCC_OscInitStruct.PLL.PLLMUL = RCC_PLL_MUL16;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV8;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV8;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK)
  {
    Error_Handler();
  }
  PeriphClkInit.PeriphClockSelection = RCC_PERIPHCLK_TIM1|RCC_PERIPHCLK_TIM17;
  PeriphClkInit.Tim1ClockSelection = RCC_TIM1CLK_HCLK;
  PeriphClkInit.Tim17ClockSelection = RCC_TIM17CLK_HCLK;
  if (HAL_RCCEx_PeriphCLKConfig(&PeriphClkInit) != HAL_OK)
  {
    Error_Handler();
  }
}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}
#ifdef USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
