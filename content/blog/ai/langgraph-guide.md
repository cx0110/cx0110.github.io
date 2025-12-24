---
title: "LangGraph 完全指南：构建复杂的AI工作流"
subtitle: "使用LangGraph构建状态驱动的AI应用"
summary: "深入学习LangGraph框架，掌握如何构建复杂的AI工作流、多智能体系统和状态管理"
authors:
  - admin
tags:
  - LangGraph
  - LangChain
  - AI工作流
  - 多智能体
categories:
  - AI & Machine Learning
date: 2025-12-24T11:00:00+08:00
lastmod: 2025-12-24T11:00:00+08:00
featured: true
draft: false
image:
  filename: ai-logo.svg
  focal_point: Smart
  preview_only: false
---

# LangGraph 完全指南：构建复杂的AI工作流

## LangGraph 简介

LangGraph是LangChain生态系统中的一个强大框架，专门用于构建有状态的、多步骤的AI应用。它使用图结构来表示复杂的工作流，支持循环、条件分支和状态管理。

## 核心概念

### 1. 状态图 (State Graph)
```python
from langgraph.graph import StateGraph
from typing import TypedDict, List

# 定义状态结构
class AgentState(TypedDict):
    messages: List[str]
    current_step: str
    context: dict
    result: str
```

### 2. 节点 (Nodes)
```python
def research_node(state: AgentState) -> AgentState:
    """研究节点：收集信息"""
    query = state["messages"][-1]
    # 执行研究逻辑
    research_result = perform_research(query)
    
    return {
        **state,
        "context": {"research": research_result},
        "current_step": "analysis"
    }

def analysis_node(state: AgentState) -> AgentState:
    """分析节点：分析信息"""
    research_data = state["context"]["research"]
    # 执行分析逻辑
    analysis_result = analyze_data(research_data)
    
    return {
        **state,
        "context": {**state["context"], "analysis": analysis_result},
        "current_step": "synthesis"
    }
```

### 3. 边 (Edges) 和条件路由
```python
def should_continue(state: AgentState) -> str:
    """条件路由：决定下一步"""
    if state["current_step"] == "research":
        return "analysis"
    elif state["current_step"] == "analysis":
        if needs_more_research(state):
            return "research"  # 循环回研究
        else:
            return "synthesis"
    else:
        return "end"
```

## 构建第一个LangGraph应用

### 简单的问答系统
```python
from langgraph.graph import StateGraph, END
from langchain_openai import ChatOpenAI

class QAState(TypedDict):
    question: str
    context: str
    answer: str
    confidence: float

def retrieve_context(state: QAState) -> QAState:
    """检索相关上下文"""
    question = state["question"]
    # 这里可以集成向量数据库检索
    context = vector_store.similarity_search(question)
    
    return {
        **state,
        "context": context
    }

def generate_answer(state: QAState) -> QAState:
    """生成答案"""
    llm = ChatOpenAI(model="gpt-4")
    
    prompt = f"""
    基于以下上下文回答问题：
    
    上下文：{state['context']}
    问题：{state['question']}
    
    请提供准确的答案：
    """
    
    response = llm.invoke(prompt)
    
    return {
        **state,
        "answer": response.content,
        "confidence": 0.8  # 可以添加置信度评估
    }

# 构建图
workflow = StateGraph(QAState)

# 添加节点
workflow.add_node("retrieve", retrieve_context)
workflow.add_node("generate", generate_answer)

# 添加边
workflow.add_edge("retrieve", "generate")
workflow.add_edge("generate", END)

# 设置入口点
workflow.set_entry_point("retrieve")

# 编译图
app = workflow.compile()
```

## 高级功能：多智能体协作

### 研究助手系统
```python
from langgraph.graph import StateGraph, END
from typing import Literal

class ResearchState(TypedDict):
    topic: str
    research_plan: str
    collected_info: List[dict]
    analysis: str
    report: str
    current_agent: str

def planner_agent(state: ResearchState) -> ResearchState:
    """规划智能体：制定研究计划"""
    llm = ChatOpenAI(model="gpt-4")
    
    prompt = f"""
    为以下主题制定详细的研究计划：
    主题：{state['topic']}
    
    请提供：
    1. 研究的关键问题
    2. 需要收集的信息类型
    3. 研究的优先级
    """
    
    plan = llm.invoke(prompt).content
    
    return {
        **state,
        "research_plan": plan,
        "current_agent": "researcher"
    }

def researcher_agent(state: ResearchState) -> ResearchState:
    """研究智能体：收集信息"""
    plan = state["research_plan"]
    
    # 模拟信息收集
    collected_info = []
    for query in extract_queries_from_plan(plan):
        info = search_information(query)
        collected_info.append({
            "query": query,
            "info": info,
            "source": "web_search"
        })
    
    return {
        **state,
        "collected_info": collected_info,
        "current_agent": "analyst"
    }

def analyst_agent(state: ResearchState) -> ResearchState:
    """分析智能体：分析信息"""
    llm = ChatOpenAI(model="gpt-4")
    
    info_summary = "\n".join([
        f"查询：{item['query']}\n信息：{item['info']}\n"
        for item in state["collected_info"]
    ])
    
    prompt = f"""
    分析以下研究信息：
    
    {info_summary}
    
    请提供：
    1. 关键发现
    2. 趋势分析
    3. 潜在问题
    4. 建议
    """
    
    analysis = llm.invoke(prompt).content
    
    return {
        **state,
        "analysis": analysis,
        "current_agent": "writer"
    }

def writer_agent(state: ResearchState) -> ResearchState:
    """写作智能体：生成报告"""
    llm = ChatOpenAI(model="gpt-4")
    
    prompt = f"""
    基于以下信息生成研究报告：
    
    主题：{state['topic']}
    研究计划：{state['research_plan']}
    分析结果：{state['analysis']}
    
    请生成一份结构化的研究报告。
    """
    
    report = llm.invoke(prompt).content
    
    return {
        **state,
        "report": report,
        "current_agent": "complete"
    }

# 构建多智能体工作流
research_workflow = StateGraph(ResearchState)

# 添加智能体节点
research_workflow.add_node("planner", planner_agent)
research_workflow.add_node("researcher", researcher_agent)
research_workflow.add_node("analyst", analyst_agent)
research_workflow.add_node("writer", writer_agent)

# 添加顺序边
research_workflow.add_edge("planner", "researcher")
research_workflow.add_edge("researcher", "analyst")
research_workflow.add_edge("analyst", "writer")
research_workflow.add_edge("writer", END)

# 设置入口点
research_workflow.set_entry_point("planner")

# 编译
research_app = research_workflow.compile()
```

## 条件分支和循环

### 自适应问答系统
```python
def quality_check(state: QAState) -> Literal["improve", "finalize"]:
    """质量检查：决定是否需要改进答案"""
    confidence = state.get("confidence", 0)
    
    if confidence < 0.7:
        return "improve"
    else:
        return "finalize"

def improve_answer(state: QAState) -> QAState:
    """改进答案"""
    llm = ChatOpenAI(model="gpt-4")
    
    prompt = f"""
    以下答案的置信度较低，请改进：
    
    问题：{state['question']}
    当前答案：{state['answer']}
    上下文：{state['context']}
    
    请提供更准确、更详细的答案：
    """
    
    improved_answer = llm.invoke(prompt).content
    
    return {
        **state,
        "answer": improved_answer,
        "confidence": min(state["confidence"] + 0.2, 1.0)
    }

# 添加条件分支
workflow.add_conditional_edges(
    "generate",
    quality_check,
    {
        "improve": "improve_answer",
        "finalize": END
    }
)

workflow.add_node("improve_answer", improve_answer)
workflow.add_edge("improve_answer", "generate")  # 循环回检查
```

## 状态持久化

### 使用检查点保存状态
```python
from langgraph.checkpoint.sqlite import SqliteSaver

# 创建检查点保存器
checkpointer = SqliteSaver.from_conn_string(":memory:")

# 编译时添加检查点
app = workflow.compile(checkpointer=checkpointer)

# 使用配置运行
config = {"configurable": {"thread_id": "conversation_1"}}

# 运行工作流
result = app.invoke(
    {"question": "什么是机器学习？"},
    config=config
)

# 获取状态历史
history = app.get_state_history(config)
for state in history:
    print(f"步骤：{state.metadata['step']}")
    print(f"状态：{state.values}")
```

## 流式处理

### 实时响应
```python
# 流式运行
for chunk in app.stream(
    {"question": "解释深度学习的原理"},
    config=config
):
    print(f"节点：{chunk.keys()}")
    for node, output in chunk.items():
        print(f"输出：{output}")
```

## 实际应用案例

### 1. 客户服务机器人
```python
class CustomerServiceState(TypedDict):
    customer_query: str
    intent: str
    customer_info: dict
    solution: str
    escalation_needed: bool

def intent_classifier(state: CustomerServiceState) -> CustomerServiceState:
    """意图分类"""
    # 使用分类模型识别客户意图
    intent = classify_intent(state["customer_query"])
    return {**state, "intent": intent}

def info_retriever(state: CustomerServiceState) -> CustomerServiceState:
    """信息检索"""
    # 根据意图检索相关信息
    info = retrieve_customer_info(state["intent"])
    return {**state, "customer_info": info}

def solution_generator(state: CustomerServiceState) -> CustomerServiceState:
    """解决方案生成"""
    # 生成解决方案
    solution = generate_solution(state["customer_query"], state["customer_info"])
    return {**state, "solution": solution}
```

### 2. 代码审查助手
```python
class CodeReviewState(TypedDict):
    code: str
    language: str
    issues: List[dict]
    suggestions: List[str]
    score: float

def syntax_checker(state: CodeReviewState) -> CodeReviewState:
    """语法检查"""
    issues = check_syntax(state["code"], state["language"])
    return {**state, "issues": issues}

def style_checker(state: CodeReviewState) -> CodeReviewState:
    """代码风格检查"""
    style_issues = check_code_style(state["code"], state["language"])
    all_issues = state["issues"] + style_issues
    return {**state, "issues": all_issues}

def security_checker(state: CodeReviewState) -> CodeReviewState:
    """安全检查"""
    security_issues = check_security(state["code"], state["language"])
    all_issues = state["issues"] + security_issues
    return {**state, "issues": all_issues}
```

## 最佳实践

### 1. 状态设计
```python
# 好的状态设计
class WellDesignedState(TypedDict):
    # 输入数据
    user_input: str
    
    # 中间结果
    processed_data: dict
    context: dict
    
    # 输出结果
    final_result: str
    
    # 元数据
    step_count: int
    execution_time: float
    confidence: float
```

### 2. 错误处理
```python
def safe_node(state: AgentState) -> AgentState:
    """安全的节点执行"""
    try:
        # 执行主要逻辑
        result = process_data(state)
        return result
    except Exception as e:
        # 记录错误并返回错误状态
        logger.error(f"节点执行失败：{e}")
        return {
            **state,
            "error": str(e),
            "status": "failed"
        }
```

### 3. 性能优化
```python
# 并行执行
from langgraph.graph import StateGraph
import asyncio

async def parallel_processing(state: AgentState) -> AgentState:
    """并行处理多个任务"""
    tasks = [
        process_task_1(state),
        process_task_2(state),
        process_task_3(state)
    ]
    
    results = await asyncio.gather(*tasks)
    
    return {
        **state,
        "results": results
    }
```

## 调试和监控

### 1. 可视化工作流
```python
# 生成图的可视化
from IPython.display import Image, display

# 显示图结构
display(Image(app.get_graph().draw_mermaid_png()))
```

### 2. 日志记录
```python
import logging

def logged_node(state: AgentState) -> AgentState:
    """带日志的节点"""
    logging.info(f"执行节点，当前状态：{state}")
    
    result = process_node(state)
    
    logging.info(f"节点完成，结果：{result}")
    return result
```

## 总结

LangGraph为构建复杂的AI工作流提供了强大的框架。通过状态图、条件分支、循环和检查点等功能，我们可以构建出智能、可靠、可扩展的AI应用。

关键优势：
- **状态管理**：清晰的状态流转
- **可组合性**：模块化的节点设计
- **可观测性**：完整的执行历史
- **容错性**：检查点和恢复机制

在实际应用中，合理设计状态结构、实现错误处理、添加监控日志是成功使用LangGraph的关键。

---

*参考资源*:
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [LangGraph Examples](https://github.com/langchain-ai/langgraph/tree/main/examples)
- [Multi-Agent Systems with LangGraph](https://blog.langchain.dev/langgraph-multi-agent-workflows/)